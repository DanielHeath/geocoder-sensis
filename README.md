# Geocoder::Sensis

Implements a Sensis Geocoder backend for the geocoder gem.

## Installation

Add this line to your application's Gemfile:

    gem 'geocoder-sensis'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install geocoder-sensis

## Usage

Geocoder.configure(
  :lookup => :sensis,
  :api_key => "..."
)

## Contributing

1. Fork it ( http://github.com/DanielHeath/geocoder-sensis/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
