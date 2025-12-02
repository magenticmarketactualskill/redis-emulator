class Redis
  module Emulator
    class Engine < ::Rails::Engine
      isolate_namespace Redis::Emulator

      config.before_configuration do
        # Ensure solid_cache is available
        require "solid_cache"
      end

      initializer "redis_emulator.configure" do
        # Set up default configuration
        Redis::Emulator.configure do |config|
          # Use Rails.cache by default
          config.cache_store = nil
        end
      end
    end
  end
end
