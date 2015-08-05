module Travis
  module Caching
    module Backends

      autoload :S3, 'travis/caching/backends/s3'

      class Base
        attr_reader :proxy

        def initialize(conf)
          @proxy = OpenStruct.new(conf)
        end

        def method_missing(method, *args)
          if proxy.respond_to? method
            proxy.send(method)
          else
            super
          end
        end
      end
    end
  end
end