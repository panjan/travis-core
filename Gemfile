source 'https://rubygems.org'

gemspec

gem 'travis-config',      github: 'final-ci/travis-config'
gem 'travis-support',     github: 'final-ci/travis-support'
gem 'travis-sidekiqs',    github: 'final-ci/travis-sidekiqs', require: nil
gem 'sidekiq-status',     github: 'utgarda/sidekiq-status', ref: 'e77d5dc2ea0a249ccbbafead21ece59d6b8caf73', require: nil
gem 'gh',                 github: 'final-ci/gh'
gem 'stash-client',       github: 'final-ci/stash-client'

gem 'addressable'
gem 'aws-sdk-v1'
gem 'json', '~> 1.8.3'

gem 'dalli'
gem 'connection_pool'
gem 'keen', '~> 0.8.6'

platform :mri do
  gem 'bunny',            '~> 0.7.9'
  gem 'pg',               '~> 0.14.0'
end

platform :jruby do
  gem 'jruby-openssl',    '~> 0.8.5'
  gem 'march_hare',       '~> 2.0.0'
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'activerecord-jdbc-adapter'
end

group :development, :test do
  gem 'micro_migrations'
end

group :test do
  gem 'rspec',            '~> 2.8.0'
  gem 'factory_girl',     '~> 2.6.0'
  gem 'database_cleaner', '~> 0.8.0'
  gem 'mocha',            '~> 0.10.0'
  gem 'webmock',          '~> 1.8.0'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-fsevent'
end

gem 'rake', '< 11.0'
