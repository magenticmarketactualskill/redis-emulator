module Redis
  module Emulator
    class Configuration
      attr_accessor :cache_store

      def initialize
        @cache_store = nil
      end

      # Get the configured cache store or default to Rails.cache
      def cache
        @cache_store || Rails.cache
      end
    end
  end
end
