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

      REQUIRED_KEYS = %w(repo_slug repo_id branch backend cache_slug)

      class InvalidPayloadError < StandardError; end

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

      error InvalidPayloadError do
        status 500
        'Payload is invalid. ' + env['sinatra.error'].message
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
        redirect url_for(token: request['token'], verb: 'GET')
      end

      put '/cache' do
        redirect url_for(token: request['token'], verb: 'PUT')
      end

      private
      def url_for(token:, verb:)
        payload = decode_payload_from(token)

        backend_config = Travis.config.backend[payload['backend']]
        backend = Travis::Caching::Backend.const_get(payload['backend'].upcase).new(backend_config)

        backend.url_for(payload.merge({'verb' => verb}))
      end

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

        decoded_payload['payload'].tap { |pl|
          raise InvalidPayloadError.new("Required keys missing: #{missing_keys(pl)}") unless all_required_keys_present?(pl)
        }
      end

      def missing_keys(payload)
        REQUIRED_KEYS - REQUIRED_KEYS.select { |k| payload[k] }
      end

      def all_required_keys_present?(payload)
        missing_keys(payload).size == 0
      end

    end
  end
end
