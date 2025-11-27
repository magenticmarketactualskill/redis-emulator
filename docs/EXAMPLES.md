# Redis Emulator Usage Examples

This document provides comprehensive examples of using Redis Emulator in various scenarios.

## Basic Setup

First, ensure Redis Emulator is properly configured in your Rails application.

### Installation

Add to your `Gemfile`:

```ruby
gem 'redis-emulator'
gem 'solid_cache', '~> 1.0'
```

Run the installer:

```bash
bundle install
rails generate redis:emulator:install
rails solid_cache:install:migrations
rails db:migrate
```

Configure your cache store in `config/environments/production.rb`:

```ruby
config.cache_store = :solid_cache_store
```

## Example 1: Simple Key-Value Storage

```ruby
# Create a client instance
redis = Redis::Emulator.new

# Store user session data
redis.set("user:1000:session", "abc123xyz")

# Retrieve session data
session_id = redis.get("user:1000:session")
# => "abc123xyz"

# Check if session exists
if redis.exists("user:1000:session") > 0
  puts "Session is active"
end

# Delete session on logout
redis.del("user:1000:session")
```

## Example 2: Rate Limiting

```ruby
redis = Redis::Emulator.new

def check_rate_limit(user_id, limit: 100)
  key = "rate_limit:#{user_id}"
  
  # Increment request count
  count = redis.incr(key)
  
  # Set expiration on first request
  if count == 1
    redis.expire(key, 3600) # 1 hour
  end
  
  # Check if limit exceeded
  if count > limit
    return false
  end
  
  true
end

# Usage
if check_rate_limit(1000)
  # Process request
  puts "Request allowed"
else
  # Reject request
  puts "Rate limit exceeded"
end
```

## Example 3: Caching Database Queries

```ruby
class UserRepository
  def initialize
    @redis = Redis::Emulator.new
  end
  
  def find_user(user_id)
    cache_key = "user:#{user_id}"
    
    # Try to get from cache
    cached_data = @redis.get(cache_key)
    return JSON.parse(cached_data) if cached_data
    
    # Fetch from database
    user = User.find(user_id)
    user_data = user.to_json
    
    # Store in cache with 1 hour expiration
    @redis.setex(cache_key, 3600, user_data)
    
    JSON.parse(user_data)
  end
  
  def invalidate_user(user_id)
    @redis.del("user:#{user_id}")
  end
end

# Usage
repo = UserRepository.new
user = repo.find_user(1000)
```

## Example 4: Distributed Counters

```ruby
redis = Redis::Emulator.new

# Page view counter
def increment_page_views(page_id)
  redis.incr("page:#{page_id}:views")
end

def get_page_views(page_id)
  views = redis.get("page:#{page_id}:views")
  views ? views.to_i : 0
end

# Usage
increment_page_views("homepage")
increment_page_views("homepage")
puts "Homepage views: #{get_page_views('homepage')}"
# => "Homepage views: 2"
```

## Example 5: Feature Flags

```ruby
class FeatureFlags
  def initialize
    @redis = Redis::Emulator.new
  end
  
  def enable_feature(feature_name)
    @redis.set("feature:#{feature_name}", "enabled")
  end
  
  def disable_feature(feature_name)
    @redis.set("feature:#{feature_name}", "disabled")
  end
  
  def feature_enabled?(feature_name)
    status = @redis.get("feature:#{feature_name}")
    status == "enabled"
  end
end

# Usage
flags = FeatureFlags.new
flags.enable_feature("new_dashboard")

if flags.feature_enabled?("new_dashboard")
  # Show new dashboard
else
  # Show old dashboard
end
```

## Example 6: Temporary Data Storage

```ruby
redis = Redis::Emulator.new

# Store email verification token
def create_verification_token(email)
  token = SecureRandom.hex(32)
  key = "verification:#{token}"
  
  # Store with 24 hour expiration
  redis.setex(key, 86400, email)
  
  token
end

def verify_token(token)
  key = "verification:#{token}"
  email = redis.get(key)
  
  if email
    # Token is valid, delete it
    redis.del(key)
    email
  else
    nil
  end
end

# Usage
token = create_verification_token("user@example.com")
# Send token via email

# Later, when user clicks verification link
email = verify_token(token)
if email
  puts "Email verified: #{email}"
else
  puts "Invalid or expired token"
end
```

## Example 7: Batch Operations

```ruby
redis = Redis::Emulator.new

# Store multiple user preferences at once
def save_user_preferences(user_id, preferences)
  args = []
  preferences.each do |key, value|
    args << "user:#{user_id}:pref:#{key}"
    args << value.to_s
  end
  
  redis.mset(*args)
end

# Retrieve multiple preferences
def get_user_preferences(user_id, pref_keys)
  keys = pref_keys.map { |key| "user:#{user_id}:pref:#{key}" }
  values = redis.mget(*keys)
  
  Hash[pref_keys.zip(values)]
end

# Usage
preferences = {
  theme: "dark",
  language: "en",
  notifications: "enabled"
}

save_user_preferences(1000, preferences)

retrieved = get_user_preferences(1000, [:theme, :language, :notifications])
# => { theme: "dark", language: "en", notifications: "enabled" }
```

## Example 8: Application Configuration

```ruby
class AppConfig
  def initialize
    @redis = Redis::Emulator.new
  end
  
  def set_config(key, value)
    @redis.set("config:#{key}", value)
  end
  
  def get_config(key, default = nil)
    value = @redis.get("config:#{key}")
    value || default
  end
  
  def reload_config(config_hash)
    # Clear existing config
    # Note: This is simplified; in production you'd track config keys
    
    # Load new config
    config_hash.each do |key, value|
      set_config(key, value)
    end
  end
end

# Usage
config = AppConfig.new
config.set_config("max_upload_size", "10485760") # 10MB
config.set_config("maintenance_mode", "false")

max_size = config.get_config("max_upload_size", "5242880").to_i
```

## Example 9: Custom Cache Store

```ruby
# Use a custom cache store for testing
cache = ActiveSupport::Cache::MemoryStore.new
redis = Redis::Emulator.new(cache: cache)

# Now all operations use the memory store
redis.set("test_key", "test_value")
redis.get("test_key")
# => "test_value"
```

## Example 10: Integration with Existing Code

If you have existing code using redis-rb, you can substitute Redis Emulator:

```ruby
# Before (using redis-rb)
# redis = Redis.new(url: ENV['REDIS_URL'])

# After (using Redis Emulator)
redis = Redis::Emulator.new

# The rest of your code remains the same
redis.set("key", "value")
value = redis.get("key")
redis.incr("counter")
```

## Testing with Redis Emulator

Redis Emulator is particularly useful in test environments:

```ruby
# spec/support/redis_emulator.rb
RSpec.configure do |config|
  config.before(:each) do
    @redis = Redis::Emulator.new(cache: ActiveSupport::Cache::MemoryStore.new)
    @redis.flushdb # Clear before each test
  end
end

# In your tests
RSpec.describe UserService do
  it "caches user data" do
    service = UserService.new(@redis)
    
    user = service.find_user(1000)
    expect(@redis.exists("user:1000")).to eq(1)
  end
end
```

## Performance Tips

While Redis Emulator provides convenience, keep these performance considerations in mind:

### Use Batch Operations

Instead of multiple individual operations:

```ruby
# Slower
redis.set("key1", "value1")
redis.set("key2", "value2")
redis.set("key3", "value3")

# Faster
redis.mset("key1", "value1", "key2", "value2", "key3", "value3")
```

### Set Appropriate Expiration Times

Always set expiration for temporary data to prevent cache bloat:

```ruby
# Good
redis.setex("temp_data", 3600, data)

# Or
redis.set("temp_data", data, ex: 3600)
```

### Use Exists Before Get

Check existence before fetching to avoid unnecessary database queries:

```ruby
if redis.exists("key") > 0
  value = redis.get("key")
  # Process value
end
```

## Migration from Redis

If you're migrating from Redis to Redis Emulator:

### Step 1: Add Redis Emulator alongside Redis

```ruby
# config/initializers/cache.rb
if Rails.env.production?
  $redis = Redis.new(url: ENV['REDIS_URL'])
else
  $redis = Redis::Emulator.new
end
```

### Step 2: Test in development/staging

Verify all operations work correctly with Redis Emulator.

### Step 3: Gradual rollout

Use feature flags to gradually switch traffic to Redis Emulator.

### Step 4: Monitor performance

Compare performance metrics and adjust as needed.

## Troubleshooting

### Issue: Operations are slow

**Solution**: Ensure Solid Cache is properly configured with appropriate database indexes.

### Issue: TTL not working as expected

**Solution**: Remember that `TTL` command returns -1 due to Solid Cache limitations. Use expiration at write time instead.

### Issue: Memory usage growing

**Solution**: Ensure you're setting expiration times on temporary data and periodically cleaning up old entries.

## Additional Resources

- [Rails Solid Cache Documentation](https://github.com/rails/solid_cache)
- [Redis Command Reference](https://redis.io/commands)
- [Redis Emulator GitHub Repository](https://github.com/example/redis-emulator)
