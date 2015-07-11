require 'sinatra'
require 'travis/support/logging'
require 'sidekiq'
require 'multi_json'
require 'ipaddr'
require 'metriks'
require 'jwt'
require 'rack/ssl'

module Travis
  module Caching
    class App < Sinatra::Base
      include Logging

      # use Rack::CommonLogger for request logging
      enable :logging, :dump_errors

      configure(:production, :staging) do
        use Rack::SSL
      end

      before do
        logger.level = 1
      end

      get '/' do
        redirect "http://docs.travis-ci.com"
      end

      # Used for uptime monitoring
      get '/uptime' do
        204
      end

      # the main endpoint for scm services
      get '/cache' do
        decoded_payload, header = JWT.decode request["token"], ENV['TRAVIS_JWT_SECRET'], true, {'iss' => 'Travis CI, GmbH', verify_iss: true}

        content_type :json
        decoded_payload.to_json
      end
    end
  end
end
