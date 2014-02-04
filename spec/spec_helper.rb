require 'bundler'
Bundler.require

require 'webmock/rspec'
require 'support/mock_sensis'

TEST_AGAINST_REAL_SENSIS = ENV["TEST_REMOTE_API"]

if TEST_AGAINST_REAL_SENSIS
  WebMock.allow_net_connect!
else
  WebMock.disable_net_connect!
end
