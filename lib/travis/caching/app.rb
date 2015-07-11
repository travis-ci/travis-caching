require 'sinatra'
require 'travis/support/logging'
require 'sidekiq'
require 'multi_json'
require 'ipaddr'
require 'metriks'
require 'jwt'

module Travis
  module Caching
    class App < Sinatra::Base
      include Logging

      # use Rack::CommonLogger for request logging
      enable :logging, :dump_errors

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
        200
      end
    end
  end
end
