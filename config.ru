$:.unshift File.expand_path('../lib', __FILE__)

require 'travis/caching'

Travis::Caching.setup

use Raven::Rack if Travis.config.sentry.dsn
run Travis::Caching::App
