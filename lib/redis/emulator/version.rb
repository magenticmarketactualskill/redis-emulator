# Ensure Redis class is loaded first
require 'redis' unless defined?(Redis)

# Extend Redis class with Emulator module
class Redis
  module Emulator
    VERSION = "0.1.0"
  end
end
