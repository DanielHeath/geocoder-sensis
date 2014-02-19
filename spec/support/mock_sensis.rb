require 'json'

def sensis_api_token
  if TEST_AGAINST_REAL_SENSIS
    File.read("secrets/token").strip
  else
    "SAMPLE_API_TOKEN"
  end
end

def sensis_api_password
  if TEST_AGAINST_REAL_SENSIS
    File.read("secrets/password").strip
  else
    "SAMPLE_API_PASSWORD"
  end
end

def mock_sensis_api(options = {})
  sensis_response = SensisResponse.new(options)

  stub_request(:post, sensis_response.uri).
    with(
      :headers => {
        'X-Auth-Token' => sensis_api_token,
        'X-Auth-Password' => sensis_api_password
    }).
    to_return(:status => sensis_response.code, :body => sensis_response.raw, :headers => {})
end

class SensisResponse
  attr_reader :request_address, :request_type, :latitude, :longitude, :street_lat, :street_lon, :granularity, :code, :state, :suburb

  def initialize(options = {})
    defaults.merge(options).each do |k, v|
      self.instance_variable_set("@#{k}", v)
    end
  end

  def defaults
    {
      suburb: "RICHMOND",
      state: "VIC",
      response_code: 200,
      granularity: "PROPERTY",
      address: "678 Victoria street, Richmond, Vic",
      latitude: -37.812571,
      longitude: 145.014029,
      street_lat: -37.1234343,
      street_lon: 145.069672934
    }
  end

  def host
    ENV["SENSIS_GEOCODE_HOST"] || "api-ems-cstage.ext.sensis.com.au"
  end

  def uri
    "https://#{host}/v2/service/geocode/#{request_type}"
  end

  def address
    request_address.to_s.upcase
  end

  def raw
    raw_hash.to_json
  end

  def raw_hash
    {results: [{
      approximated: false,
      granularity: granularity,
      address: {
        display: address,
        state: state,
        suburb: suburb
      },
      geometry: {
        centre: {
            lon: longitude,
            lat: latitude
        },
        street: {
            lon: street_lon,
            lat: street_lat
        }
      }
    }]}
  end

end
