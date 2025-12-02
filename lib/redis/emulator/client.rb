class Redis
  module Emulator
    # Redis client emulator that uses Rails Solid Cache as the backend
    # Provides a Redis-compatible interface for basic cache operations
    class Client
      attr_reader :cache

      def initialize(options = {})
        @cache = options[:cache] || Rails.cache
      end

      # GET command - retrieve value by key
      def get(key)
        @cache.read(key)
      end

      # SET command - set key to hold the string value
      # Options:
      #   ex: Set the specified expire time, in seconds
      #   px: Set the specified expire time, in milliseconds
      #   nx: Only set the key if it does not already exist
      #   xx: Only set the key if it already exists
      def set(key, value, **options)
        if options[:nx] && @cache.exist?(key)
          return nil
        end

        if options[:xx] && !@cache.exist?(key)
          return nil
        end

        expires_in = nil
        if options[:ex]
          expires_in = options[:ex].to_i.seconds
        elsif options[:px]
          expires_in = (options[:px].to_i / 1000.0).seconds
        end

        if expires_in
          @cache.write(key, value, expires_in: expires_in)
        else
          @cache.write(key, value)
        end

        "OK"
      end

      # DEL command - delete one or more keys
      def del(*keys)
        count = 0
        keys.each do |key|
          if @cache.exist?(key)
            @cache.delete(key)
            count += 1
          end
        end
        count
      end

      # EXISTS command - check if key exists
      def exists(*keys)
        count = 0
        keys.each do |key|
          count += 1 if @cache.exist?(key)
        end
        count
      end

      # EXPIRE command - set a timeout on key
      def expire(key, seconds)
        return 0 unless @cache.exist?(key)
        
        value = @cache.read(key)
        @cache.write(key, value, expires_in: seconds.to_i.seconds)
        1
      end

      # TTL command - get the time to live for a key in seconds
      # Returns -2 if key does not exist
      # Returns -1 if key exists but has no expiration
      def ttl(key)
        return -2 unless @cache.exist?(key)
        
        # Solid Cache doesn't provide TTL information directly
        # This is a limitation of the emulation
        -1
      end

      # KEYS command - find all keys matching the given pattern
      # Note: This is a simplified implementation
      def keys(pattern = "*")
        # Solid Cache doesn't provide a way to list all keys
        # This is a limitation of the emulation
        []
      end

      # FLUSHDB command - remove all keys from the current database
      def flushdb
        @cache.clear
        "OK"
      end

      # PING command - ping the server
      def ping(message = nil)
        message || "PONG"
      end

      # INFO command - get information and statistics about the server
      def info(section = nil)
        "# Redis Emulator\r\nredis_version:emulated\r\nredis_mode:standalone\r\n"
      end

      # INCR command - increment the integer value of a key by one
      def incr(key)
        value = @cache.read(key) || 0
        new_value = value.to_i + 1
        @cache.write(key, new_value)
        new_value
      end

      # DECR command - decrement the integer value of a key by one
      def decr(key)
        value = @cache.read(key) || 0
        new_value = value.to_i - 1
        @cache.write(key, new_value)
        new_value
      end

      # INCRBY command - increment the integer value of a key by the given amount
      def incrby(key, increment)
        value = @cache.read(key) || 0
        new_value = value.to_i + increment.to_i
        @cache.write(key, new_value)
        new_value
      end

      # DECRBY command - decrement the integer value of a key by the given amount
      def decrby(key, decrement)
        value = @cache.read(key) || 0
        new_value = value.to_i - decrement.to_i
        @cache.write(key, new_value)
        new_value
      end

      # MGET command - get the values of all the given keys
      def mget(*keys)
        keys.map { |key| @cache.read(key) }
      end

      # MSET command - set multiple keys to multiple values
      def mset(*args)
        raise ArgumentError, "wrong number of arguments" if args.size.odd?
        
        args.each_slice(2) do |key, value|
          @cache.write(key, value)
        end
        "OK"
      end

      # SETEX command - set the value and expiration of a key
      def setex(key, seconds, value)
        @cache.write(key, value, expires_in: seconds.to_i.seconds)
        "OK"
      end

      # SETNX command - set the value of a key, only if the key does not exist
      def setnx(key, value)
        if @cache.exist?(key)
          0
        else
          @cache.write(key, value)
          1
        end
      end

      # GETSET command - set the string value of a key and return its old value
      def getset(key, value)
        old_value = @cache.read(key)
        @cache.write(key, value)
        old_value
      end

      # APPEND command - append a value to a key
      def append(key, value)
        current = @cache.read(key) || ""
        new_value = current.to_s + value.to_s
        @cache.write(key, new_value)
        new_value.length
      end

      # STRLEN command - get the length of the value stored in a key
      def strlen(key)
        value = @cache.read(key)
        value ? value.to_s.length : 0
      end

      # Support for pipelined operations (simplified)
      def pipelined
        yield self if block_given?
      end

      # Support for multi/exec transactions (simplified)
      def multi
        yield self if block_given?
      end

      # Close connection (no-op for cache-based implementation)
      def close
        true
      end

      # Check if connected (always true for cache-based implementation)
      def connected?
        true
      end
    end
  end
end
