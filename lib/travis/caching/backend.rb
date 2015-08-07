require 'ostruct'

module Travis
  module Caching
    module Backend

      autoload :S3, 'travis/caching/backend/s3'

      class Base
        attr_reader :proxy, :time

        # @proxy is initiated by reading the config for the backend
        # specified in config.
        # it acts as a proxy to the config values
        # note that the subclass from Base should not define
        # methods with names specified in config, or else
        # confusion will arise

        def initialize(conf)
          @proxy = OpenStruct.new(conf)
          @time  = Time.now
        end

        def method_missing(method, *args)
          if proxy.respond_to? method
            proxy.send(method, *args)
          else
            super
          end
        end

        def url_for(payload)
          # receives a hash with keys Travis::Caching::App::REQUIRED_KEYS + 'verb'
          # the task for #url_for is to turn this hash into a URL
          # to which the calls to `/cache` (GET and PUT) redirect.
          raise "#{__method__} needs to be overridden by a sublass of #{self.class.name}"
        end
      end
    end
  end
end