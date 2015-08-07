require "geocoder"
require "geocoder/sensis/version"

module Geocoder

  module Lookup

    # Yuck. Geocoder gem doesn't offer a straightforward way
    # to register new implementations. This module patches
    # the 'sensis' lookup method into the known geocoders array
    module AddSensisToStreetServices
      def street_services
        super + [:sensis_unstructured, :sensis_structured]
      end
    end
    extend AddSensisToStreetServices

    # Actual implementation
    class SensisBase < Base

      def required_api_key_parts
        ["auth token", "auth password"]
      end

      def query_url(query)
        "https://#{sensis_host}/v2/service/geocode/#{request_type}" + url_query_string(query)
      end

      def protocol
        "https"
      end

      def cache_key(query)
        query.to_s
      end

      def results(query)
        doc = fetch_data(query)
        return [] unless doc
        raise Exception.new('Incorrect API key') if doc["code"] == 401
        doc["results"]
      end

      ##
      # Override the base method because it's hard-coded to use Get.
      # TODO: Raise PR upstream to allow other request methods.
      #
      def make_api_request(query)
        response = timeout(configuration.timeout) do
          uri = URI.parse(query_url(query))
          http_client.start(uri.host, uri.port, :use_ssl => true) do |client|
            client.ssl_version = :TLSv1
            client.ciphers = ['RC4-SHA']
            req = Net::HTTP::Post.new(uri.request_uri, configuration.http_headers)
            req.basic_auth(uri.user, uri.password) if uri.user and uri.password
            req.body = sensis_query_json(query)
            req.content_type = 'application/json'
            req['X-Auth-Token'] = configuration.api_key[0]
            req['X-Auth-Password'] = configuration.api_key[1]
            client.request(req)
          end
        end
        case response.code.to_i
        when 200
          return response
        when 400
          raise_error ::Geocoder::InvalidRequest, "Bad Request: #{response.body}"
        else
          raise_error ::Geocoder::Error, "Unable to access Sensis API: #{response.code}. Body:\n#{response.body}"
        end
        response
      end

      def result_class
        ::Geocoder::Result::Sensis
      end

    private

      def sensis_host
        ENV["SENSIS_GEOCODE_HOST"] || "api-ems-stage.ext.sensis.com.au"
      end

      # Structured or unstructured
      def request_type
        fail
      end

      # A json hash
      def sensis_query_json(query)
        fail
      end

    end

    class SensisUnstructured < SensisBase
      def name
        :sensis_unstructured
      end

      def request_type
        :unstructured
      end

      def sensis_query_json(query)
        {"query" => query.text}.to_json
      end

    end

    class SensisStructured < SensisBase

      def name
        :sensis_structured
      end

      def request_type
        :structured
      end

      def sensis_query_json(query)
        {"address" => query.text}.to_json
      end

    end

  end

  module Result

    class Sensis < Base

      def coordinates
        ['lat', 'lon'].map{ |i| @data['geometry']['centre'][i] }
      end

      def precision
        granularity
      end

      def granularity
        @data["granularity"]
      end
    end

  end
end
