source 'https://rubygems.org'

ruby '2.1.6'

gem 'travis-support',  github: 'travis-ci/travis-support'

gem 'sinatra',         '~> 1.4.2'
gem 'rake',            '~> 0.9.2.2'
gem 'redis'
gem 'multi_json'

gem 'sentry-raven',    github: 'getsentry/raven-ruby'

gem 'activesupport',   '~> 3.2.13'
gem 'hashr',           '~> 0.0.19'

gem 'metriks'
gem 'metriks-librato_metrics'

gem 'yajl-ruby',       '~> 1.1.0'

gem 'unicorn',         '~> 4.6.2'

gem 'sidekiq'

gem 'jwt'

group :development, :test do
  gem 'rspec'
end

group :development do
  gem 'foreman',       '~> 0.41.0'
end

group :test do
  gem 'rack-test'
  gem 'webmock'
end
