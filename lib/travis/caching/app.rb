require 'sinatra'
require 'travis/support/logging'
require 'sidekiq'
require 'multi_json'
require 'ipaddr'
require 'metriks'
require 'jwt'
require 'rack/ssl'
require 'travis/caching/s3/aws4_signature'

module Travis
  module Caching
    class App < Sinatra::Base
      include Logging

      KeyPair = Struct.new(:id, :secret)

      Location = Struct.new(:scheme, :region, :bucket, :path) do
        def hostname
          "#{bucket}.#{region == 'us-east-1' ? 's3' : "s3-#{region}"}.amazonaws.com"
        end
      end

      attr_reader :jwt_config, :aws_config


      # use Rack::CommonLogger for request logging
      enable :logging, :dump_errors

      configure(:production, :staging) do
        use Rack::SSL
      end

      before do
        logger.level = 1
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
        @jwt_config ||= Travis.config.jwt
        @aws_config ||= Travis.config.aws

        decoded_payload, header = JWT.decode(
          request["token"],
          jwt_config.secret,
          true,
          {
            'iss' =>  jwt_config.issuer,
            verify_iss: true,
            verify_iat: true,
            algorithm: jwt_config.algorithm # verify algorithm is one we expect
          }
        )

        payload      = decoded_payload['playload']
        aws_id       = aws_config.id
        aws_secret   = aws_config.secret
        aws_region   = aws_config.region
        aws_bucket   = aws_config.bucket

        content_type :json
        decoded_payload.to_json
      end
    end
  end
end
