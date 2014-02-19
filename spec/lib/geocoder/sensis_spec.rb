require 'spec_helper'
require 'geocoder/sensis'

describe Geocoder::Sensis do

  describe "Geocoding an address via unstructured api" do
    before do
      Geocoder.configure(
        :lookup => :sensis_unstructured,
        :api_key => [sensis_api_token, sensis_api_password],
        :use_https => true,
        :timeout => 30000
      )
    end

    it "patches the known geocoders array to include sensis" do
      expect(Geocoder::Lookup.street_services).to include(:sensis_unstructured)
      expect(Geocoder::Lookup.street_services).to include(:sensis_structured)
    end

    it "connects to sensis" do
      api = mock_sensis_api :request_type => :unstructured
      Geocoder.coordinates('12 Powlett Street, East Melbourne')
      api.should have_been_requested
    end

    it "returns the geocode from sensis" do
      mock_sensis_api :request_type => :unstructured,
        :latitude => 44.66,
        :longitude => 55.66
      coords = Geocoder.coordinates('12 Powlett Street, East Melbourne')
      expect(coords).to eq [44.66, 55.66]
    end

  end

  describe "Geocoding an address via structured api" do

    before do
      Geocoder.configure(
        :lookup => :sensis_structured,
        :api_key => [sensis_api_token, sensis_api_password],
        :use_https => true,
        :timeout => 30000,
        :always_raise => :all,
      )
    end

    describe "with an invalid address (returning http 400)" do
      it "throws an ::Geocoder::InvalidRequest" do
        mock_sensis_api :request_type => :structured, :response_code => 400
        expect {
          Geocoder.coordinates({})
        }.to raise_error(::Geocoder::InvalidRequest)
      end
    end

    describe "when sensis is down (returning http 500)" do
      it "throws an ::Geocoder::Error" do
        mock_sensis_api :request_type => :structured, :response_code => 500
        expect {
          Geocoder.coordinates({})
        }.to raise_error(::Geocoder::Error)
      end
    end

    describe "with a valid address" do
      before do
        mock_sensis_api(:request_type => :structured,
                  :address => '12 Powlett Street, East Melbourne',
                  :latitude => 44.66,
                  :longitude => 55.66)
      end

      it "returns the geocode from sensis" do
        coords = Geocoder.coordinates(
          "state" => "Vic",
          "suburb" => "Richmond",
          "postcode" => "3121",
          "number" => "9",
          "street" => {
            "name" => "Victoria",
            "type" => "Street",
            "suffix" => ""
        })

        expect(coords).to eq [44.66, 55.66]
      end

    end
  end

end
