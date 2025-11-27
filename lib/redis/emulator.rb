require "redis/emulator/version"
require "redis/emulator/engine"
require "redis/emulator/client"
require "redis/emulator/configuration"

module Redis
  module Emulator
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    # Create a new Redis emulator client
    def self.new(options = {})
      Client.new(options)
    end
  end
end
