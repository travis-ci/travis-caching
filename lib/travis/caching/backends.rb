require 'ostruct'

module Travis
  module Caching
    module Backends

      autoload :S3, 'travis/caching/backends/s3'

      class Base
        attr_reader :proxy, :time

        def initialize(conf)
          @proxy = OpenStruct.new(conf)
          @time  = Time.now
        end

        def method_missing(method, *args)
          if proxy.respond_to? method
            proxy.send(method)
          else
            super
          end
        end

        def url_for(payload)
          raise "#{__method__} needs to be overridden by a sublass of #{self.class.name}"
        end
      end
    end
  end
end