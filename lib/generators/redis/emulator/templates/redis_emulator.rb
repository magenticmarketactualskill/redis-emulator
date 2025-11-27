# Redis Emulator Configuration
# This initializer configures the Redis emulator to use Rails Solid Cache

Redis::Emulator.configure do |config|
  # Optionally specify a custom cache store
  # By default, it uses Rails.cache
  # config.cache_store = Rails.cache
end

# Example usage:
# redis = Redis::Emulator.new
# redis.set("key", "value")
# redis.get("key") # => "value"
