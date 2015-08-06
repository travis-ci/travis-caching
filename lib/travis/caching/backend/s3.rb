require 'openssl'
require 'uri'
require 'addressable/uri'
require 'digest/sha1'

module Travis
  module Caching
    module Backend
      class S3 < Base
        # needs
        # - id
        # - secret
        # - region
        # - bucket
        # - expires

        attr_reader :key_pair, :location, :verb

        def url_for(payload)
          @verb = payload['verb']

          @key_pair = OpenStruct.new(id: id, secret: secret)

          # TODO: construct 'path' based on payload
          # path = …
          path = '/a/b/c/cache.tgz'
          @location = OpenStruct.new(scheme: scheme, region: region, bucket: bucket, path: path)

          query = canonical_query_params.dup
          query["X-Amz-Signature"] = OpenSSL::HMAC.hexdigest("sha256", signing_key, string_to_sign)

          Addressable::URI.new(
            scheme: location.scheme,
            host: location.hostname,
            path: location.path,
            query_values: query,
          )
        end

        private

        def scheme
          'https'
        end

        def hostname
          "#{bucket}.#{region == 'us-east-1' ? 's3' : "s3-#{region}"}.amazonaws.com"
        end

        def date
          time.utc.strftime '%Y%m%d'
        end

        def timestamp
          time.utc.strftime '%Y%m%dT%H%M%SZ'
        end

        def canonical_query_params
          @canonical_query_params ||= {
           'X-Amz-Algorithm' => 'AWS4-HMAC-SHA256',
           'X-Amz-Credential' => "#{key_pair.id}/#{date}/#{location.region}/s3/aws4_request",
           'X-Amz-Date' => timestamp,
           'X-Amz-Expires' => expires,
           'X-Amz-SignedHeaders' => 'host',
          }
        end

        def query_string
          canonical_query_params.map { |key, value|
            "#{URI.encode(key.to_s, /[^~a-zA-Z0-9_.-]/)}=#{URI.encode(value.to_s, /[^~a-zA-Z0-9_.-]/)}"
          }.join('&')
        end

        def request_sha
          OpenSSL::Digest::SHA256.hexdigest(
            [
              verb,
              location.path,
              query_string,
              "host:#{location.hostname}\n",
              'host',
              'UNSIGNED-PAYLOAD'
            ].join("\n")
          )
        end

        def string_to_sign
          [
            'AWS4-HMAC-SHA256',
            timestamp,
            "#{date}/#{location.region}/s3/aws4_request",
            request_sha
          ].join("\n")
        end

        def signing_key
          @signing_key ||= recursive_hmac(
            "AWS4#{key_pair.secret}",
            date,
            location.region,
            's3',
            'aws4_request',
          )
        end

        def recursive_hmac(*args)
          args.inject { |key, data| OpenSSL::HMAC.digest('sha256', key, data) }
        end

      end
    end
  end
end
