require 'sinatra'
require 'travis/support/logging'
require 'sidekiq'
require 'multi_json'
require 'ipaddr'
require 'metriks'
require 'jwt'
require 'rack/ssl'
require 'travis/caching/backend'

module Travis
  module Caching
    class App < Sinatra::Base
      include Logging

      attr_reader :jwt_config

      # use Rack::CommonLogger for request logging
      enable :logging, :dump_errors

      configure(:production, :staging) do
        use Rack::SSL
      end

      before do
        logger.level = 1
      end

      before '/cache' do
        @jwt_config ||= Travis.config.jwt

      end

      error JWT::DecodeError do
        status 500
        'JWT decoding failed'
      end

      get '/' do
        redirect "http://docs.travis-ci.com"
      end

      # Used for uptime monitoring
      get '/uptime' do
        204
      end

      # the main endpoint for caching services
      get '/cache' do
        payload = decode_payload_from(request['token'])

        backend_config = Travis.config.backend[payload['backend']]
        backend = Travis::Caching::Backend.const_get(payload['backend'].upcase).new(backend_config)

        redirect backend.url_for(payload.merge({'verb' => 'GET'}))
      end

      put '/cache' do
        payload = decode_payload_from(request['token'])

        backend_config = Travis.config.backend[payload['backend']]
        backend = Travis::Caching::Backend.const_get(payload['backend'].upcase).new(backend_config)

        redirect backend.url_for(payload.merge({'verb' => 'PUT'}))
      end

      private
      def decode_payload_from(token)
        decoded_payload, header = JWT.decode(
          token,
          jwt_config.secret,
          true,
          {
            'iss' =>  jwt_config.issuer,
            verify_iss: true,
            verify_iat: true,
            algorithm: jwt_config.algorithm # verify algorithm is one we expect
          }
        )

        decoded_payload['payload']
      end

    end
  end
end
