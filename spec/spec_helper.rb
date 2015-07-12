ENV["RACK_ENV"] ||= 'test'

require 'rack/test'
require 'logger'
require 'webmock/rspec'

require 'travis/caching'
require 'support/webmock'
require 'payloads'

require 'sinatra/test_helpers'

ENV['travis_config'] =  <<-EOF
redis:
  url: redis://tok:en@url.com:12345
jwt:
  issuer: test_jwt_issuer
  secret: superduper
aws:
  id: foo
  secret: bar
  region: us-east-1
  bucket: mybucket
EOF

Travis.logger = ::Logger.new(StringIO.new)

Travis::Caching.setup
Travis::Caching.connect

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
