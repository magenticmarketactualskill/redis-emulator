# Redis Emulator

A Ruby on Rails engine gem that provides Redis emulation using Rails Solid Cache as the persistence layer. This gem allows you to use a database-backed cache store as a drop-in replacement for Redis, compatible with the redis-rb gem.

## Features

- **Redis-compatible interface**: Implements common Redis commands through a familiar API
- **Solid Cache backend**: Uses Rails Solid Cache for database-backed persistence
- **Easy integration**: Works seamlessly with existing Rails applications
- **Comprehensive testing**: Includes both RSpec and Cucumber test suites
- **No external dependencies**: No need for a separate Redis server

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redis-emulator'
gem 'solid_cache', '~> 1.0'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install redis-emulator
```

## Setup

### 1. Install Solid Cache

First, install and configure Solid Cache in your Rails application:

```bash
rails solid_cache:install:migrations
rails db:migrate
```

### 2. Configure Cache Store

In your Rails environment configuration (e.g., `config/environments/production.rb`):

```ruby
config.cache_store = :solid_cache_store
```

### 3. Install Redis Emulator

Generate the initializer:

```bash
rails generate redis:emulator:install
```

This creates `config/initializers/redis_emulator.rb` with default configuration.

## Usage

### Basic Operations

```ruby
# Create a new Redis Emulator client
redis = Redis::Emulator.new

# Set and get values
redis.set("mykey", "myvalue")
redis.get("mykey")  # => "myvalue"

# Set with expiration (in seconds)
redis.set("tempkey", "tempvalue", ex: 60)

# Set with expiration (in milliseconds)
redis.set("tempkey", "tempvalue", px: 60000)

# Set only if key doesn't exist
redis.set("mykey", "newvalue", nx: true)

# Set only if key exists
redis.set("mykey", "newvalue", xx: true)
```

### Key Operations

```ruby
# Delete keys
redis.del("key1", "key2")  # => 2

# Check if key exists
redis.exists("mykey")  # => 1

# Set expiration on existing key
redis.expire("mykey", 60)  # => 1

# Get time to live (returns -1 for keys without expiration)
redis.ttl("mykey")  # => -1
```

### String Operations

```ruby
# Increment/decrement
redis.incr("counter")        # => 1
redis.decr("counter")        # => 0
redis.incrby("counter", 5)   # => 5
redis.decrby("counter", 2)   # => 3

# Multiple operations
redis.mset("key1", "value1", "key2", "value2")
redis.mget("key1", "key2")   # => ["value1", "value2"]

# Set with expiration
redis.setex("key", 60, "value")

# Set if not exists
redis.setnx("key", "value")  # => 1 (success) or 0 (key exists)

# Get and set
redis.getset("key", "newvalue")  # => "oldvalue"

# Append to value
redis.append("key", " world")  # => 11 (length of resulting string)

# Get string length
redis.strlen("key")  # => 11
```

### Database Operations

```ruby
# Clear all keys
redis.flushdb  # => "OK"

# Ping server
redis.ping  # => "PONG"
redis.ping("hello")  # => "hello"

# Get server info
redis.info  # => "# Redis Emulator\r\nredis_version:emulated\r\n..."
```

### Advanced Features

```ruby
# Pipelined operations (simplified implementation)
redis.pipelined do |pipe|
  pipe.set("key1", "value1")
  pipe.set("key2", "value2")
end

# Transactions (simplified implementation)
redis.multi do |txn|
  txn.set("key1", "value1")
  txn.incr("counter")
end
```

### Custom Cache Store

You can specify a custom cache store:

```ruby
# In config/initializers/redis_emulator.rb
Redis::Emulator.configure do |config|
  config.cache_store = ActiveSupport::Cache::MemoryStore.new
end

# Or per-instance
cache = ActiveSupport::Cache::MemoryStore.new
redis = Redis::Emulator.new(cache: cache)
```

## Supported Redis Commands

The following Redis commands are currently supported:

### Key Commands
- `GET`, `SET`, `DEL`, `EXISTS`, `EXPIRE`, `TTL`

### String Commands
- `INCR`, `DECR`, `INCRBY`, `DECRBY`
- `MGET`, `MSET`, `SETEX`, `SETNX`, `GETSET`
- `APPEND`, `STRLEN`

### Server Commands
- `FLUSHDB`, `PING`, `INFO`

### Connection Commands
- `CLOSE`, `CONNECTED?`

### Transaction Commands (Simplified)
- `PIPELINED`, `MULTI`

## Limitations

Due to the nature of using Solid Cache as the backend, some Redis features have limitations:

1. **TTL Information**: The `TTL` command always returns `-1` for existing keys, as Solid Cache doesn't expose TTL information
2. **KEYS Command**: Not implemented, as Solid Cache doesn't provide a way to list all keys
3. **Complex Data Structures**: Only string operations are supported; lists, sets, hashes, and sorted sets are not implemented
4. **Pub/Sub**: Not supported
5. **Transactions**: Simplified implementation without true atomicity guarantees

## Architecture

Redis Emulator is built as a Rails engine that provides:

- **Client Layer**: `Redis::Emulator::Client` - Implements Redis-compatible commands
- **Persistence Layer**: Uses Rails Solid Cache (database-backed cache store)
- **Configuration Layer**: `Redis::Emulator::Configuration` - Manages cache store configuration

## Testing

The gem includes comprehensive test coverage:

### RSpec Tests

```bash
bundle exec rspec
```

### Cucumber Tests

```bash
bundle exec cucumber
```

## Development

After checking out the repo, run:

```bash
bundle install
```

To run tests:

```bash
bundle exec rspec
bundle exec cucumber
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/example/redis-emulator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Use Cases

Redis Emulator is ideal for:

1. **Development and Testing**: Use database-backed cache without running a separate Redis server
2. **Small Applications**: Simple caching needs without Redis infrastructure
3. **Heroku and PaaS**: Environments where Redis add-ons are costly
4. **Migration Path**: Gradual transition from Redis to Solid Cache
5. **Simplified Deployment**: Reduce infrastructure complexity

## Performance Considerations

While Redis Emulator provides Redis compatibility, performance characteristics differ:

- **Database I/O**: Operations involve database reads/writes instead of in-memory operations
- **Latency**: Higher latency compared to native Redis
- **Throughput**: Lower throughput for high-frequency operations
- **Best For**: Low to medium traffic applications where simplicity is prioritized over performance

## Comparison with Redis

| Feature | Redis | Redis Emulator |
|---------|-------|----------------|
| Storage | In-memory | Database-backed |
| Persistence | Optional (RDB/AOF) | Always persistent |
| Data Structures | Full support | Strings only |
| Performance | Very high | Moderate |
| Setup Complexity | Separate service | Rails integrated |
| Infrastructure | Additional server | Uses existing DB |
| TTL Support | Full | Limited |
| Pub/Sub | Yes | No |

## Version History

### 0.1.0
- Initial release
- Basic string operations
- Solid Cache integration
- RSpec and Cucumber test suites

## Credits

Built with:
- [Ruby on Rails](https://rubyonrails.org/)
- [Solid Cache](https://github.com/rails/solid_cache)
- [redis-rb](https://github.com/redis/redis-rb)
