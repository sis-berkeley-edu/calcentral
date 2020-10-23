source 'https://rubygems.org'

# The core framework
# https://github.com/rails/rails
gem 'rails', '6.0.3.4'

# https://github.com/ruby/rake
gem 'rake'

# Connects business objects and REST web services
# https://github.com/rails/activeresource
gem 'activeresource', '~>5.1.1'

# Benchmark and profile your Rails apps
# https://github.com/rails/rails-perftest
gem 'rails-perftest', '~>0.0.7'

# Oracle enhanced adapter for ActiveRecord
# https://github.com/rsim/oracle-enhanced
gem 'activerecord-oracle_enhanced-adapter', '~> 6.0.2', group: [:development, :production]

# JRuby's ActiveRecord adapter using JDBC (Oracle and H2 support)
# https://github.com/jruby/activerecord-jdbc-adapter
gem 'activerecord-jdbc-adapter', '60.2'

# An ActiveRecord null database adapter for greater speed and isolation in unit tests
# https://github.com/nulldb/nulldb
gem 'activerecord-nulldb-adapter', '~> 0.4.0'

# SQLite adapter for activerecord
# https://github.com/jruby/activerecord-jdbc-adapter
gem 'activerecord-jdbcsqlite3-adapter', '60.2', group: [:development, :test]

# A JSON implementation as a Ruby extension in C
# http://flori.github.com/json/
gem 'json', '~> 2.3.1'

# CAS Strategy for OmniAuth. ETS maintains its own fork with SAML Ticket Validator capability,
# provided by Steven Hansen.
gem 'omniauth-cas', '~> 1.1.1', git: 'https://github.com/sis-berkeley-edu/omniauth-cas.git'

# LDAP
# https://github.com/ruby-ldap/ruby-net-ldap
gem 'net-ldap', '~> 0.16.3'

# secure_headers provides x-frame, csp and other http headers
# https://github.com/twitter/secure_headers
gem 'secure_headers', '~> 6.3.1'

# HTTP client library
# https://github.com/jnunemaker/httparty
gem 'httparty', '~> 0.18.1'

# Google Auth Library for Ruby
# https://github.com/googleapis/google-auth-library-ruby
gem 'googleauth', '~> 0.9.0'

# REST client for Google APIs
# https://github.com/googleapis/google-api-ruby-client
gem 'google-api-client', '~> 0.31.0'

# Memcached client
# https://github.com/petergoldstein/
gem 'dalli', '~> 2.7.11'

# Connection Pool
# Used to pool connections to memcached via dalli
# https://github.com/mperham/connection_pool
gem 'connection_pool', '~> 2.2.3'

# Provides telnet client functionality
# https://github.com/ruby/net-telnet
gem 'net-telnet', '~> 0.2.0'

# smarter logging
# https://rubygems.org/gems/log4r
# https://github.com/colbygk/log4r
gem 'log4r', '~> 1.1.10'

# for easier non-DB-backed models
# https://github.com/cgriego/active_attr
gem 'active_attr', '~> 0.15.0'

# for production deployment
gem 'jruby-activemq', '~> 5.13.0', git: 'https://github.com/sis-berkeley-edu/jruby-activemq.git'

# To support SSL TLSv1.2.
# jruby-openssl versions 0.9.8 through 0.9.16 trigger runaway memory consumption in CalCentral.
# Track progress at https://github.com/jruby/jruby-openssl/issues/86 and SISRP-18781.
gem 'jruby-openssl', '0.10.4'

# Addressable is a replacement for the URI implementation that is part of Ruby's standard library.
# https://github.com/sporkmonger/addressable
gem 'addressable', '~> 2.7.0'

# for parsing formatted html
# https://github.com/sparklemotion/nokogiri
gem 'nokogiri', '~> 1.10.10', :platforms => :jruby

# for parsing paged feeds
# https://github.com/asplake/link_header
gem 'link_header', '~> 0.0.8'

# Background jobs
# https://github.com/ruby-concurrency/concurrent-ruby
gem 'concurrent-ruby', '~> 1.1.7'

# for building a WAR to deploy on Tomcat
# https://github.com/jruby/warbler
gem 'warbler', '~> 2.0.5'

# https://github.com/jruby/jruby/tree/master/maven/jruby-jars
gem 'jruby-jars', '9.2.13.0'

# simple DSL to retry failed code blocks
# for trying, and trying again, and then giving up.
# https://github.com/kamui/retriable
gem 'retriable', '~> 3.1.2'

# authorization abstraction layer
# https://github.com/varvet/pundit
gem 'pundit', '~> 0.3.0'

# https://github.com/ryanb/cancan
gem 'cancan', '~> 1.6.10'

# https://github.com/net-ssh/net-ssh
# v3 requires Ruby 2.0
gem 'net-ssh', '5.0.2'

# Support for iCalendar files
# https://github.com/icalendar/icalendar
gem 'icalendar', '~> 2.6.1'

group :development, :production do
  # Remote automation tool used for deployment
  # latest: v3.11.2
  # https://github.com/capistrano/capistrano
  # V3 is a total rewrite, see https://github.com/capistrano/capistrano/blob/3f8f6502/CHANGELOG.md#300
  gem 'capistrano', '2.15.5'

  # RVM support for Capistrano
  # latest: v1.5.6
  # https://github.com/rvm/rvm-capistrano
  gem 'rvm-capistrano', '1.3.4', require: false
end

group :development, :test do

  # RSpec for Rails-3+
  # https://github.com/rspec/rspec-rails
  gem 'rspec-rails', '~> 4.0.1'

  # `its` for RSpec 3 extracted from rspec-core 2.x
  # https://github.com/rspec/rspec-its
  gem 'rspec-its', '~> 1.3.0'

  # Collection cardinality matchers, extracted from rspec-expectations
  # https://github.com/rspec/rspec-collection_matchers
  gem 'rspec-collection_matchers', '~> 1.2.0'

  # Code coverage for Ruby 1.9 with a powerful configuration library and automatic merging of coverage across test suites
  # https://rubygems.org/gems/simplecov
  gem 'simplecov', '~> 0.19.0', require: false
  gem 'simplecov-html', '~> 0.12.2', require: false

  # Webmock is not thread-safe and should never be enabled in production-like environments.
  gem 'webmock', '~> 3.8.3'

  # Currently needed by RubyMine.
  # https://test-unit.github.io/
  gem 'test-unit'
end

group :development do
  # A better development webserver than WEBrick, especially on JRuby
  # https://puma.io/
  gem 'puma'

  # Debugging support for Eclipse and RubyMine
  # https://github.com/ruby-debug/ruby-debug-ide
  gem 'ruby-debug-ide', '~> 0.7.0'
end

group :test do
  # PageObject pattern for selenium-webdriver (browser based testing)
  # https://github.com/cheezy/page-object
  gem 'page-object', '~> 2.2.6'

  # RSpec results that Hudson + Bamboo + xml happy CI servers can read.
  # https://github.com/sj26/rspec_junit_formatter
  gem 'rspec_junit_formatter', '~> 0.4.1'
end

group :shell_debug do
  # Ruby debugging
  # https://github.com/ruby-debug/ruby-debug
  gem 'ruby-debug', '>= 0.10.5.rc9'
end
