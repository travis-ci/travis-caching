require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

ENV["RACK_ENV"] ||= 'test'

require 'rack/test'
require 'logger'
require 'webmock/rspec'

require 'travis/caching'
require 'support/webmock'

require 'sinatra/test_helpers'

Travis.logger = ::Logger.new(StringIO.new)

Travis::Caching.setup

RSpec.configure do |c|
  c.include Rack::Test::Methods
  c.include Sinatra::TestHelpers, :include_sinatra_helpers

  c.alias_example_to :fit, :focused => true
  c.filter_run :focused => true
  c.run_all_when_everything_filtered = true

  c.before :all do
    Support::Webmock.mock!
  end
end

WebMock.disable_net_connect!(:allow => "codeclimate.com")
