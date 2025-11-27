# Cucumber environment for Redis Emulator gem
ENV['RAILS_ENV'] ||= 'test'

# Load the dummy Rails app
require File.expand_path('../../test/dummy/config/environment', __dir__)

# Load Redis Emulator
require 'redis/emulator'

# Load RSpec expectations for step definitions
require 'rspec/expectations'

World(RSpec::Matchers)
