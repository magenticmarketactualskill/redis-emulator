# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-27

### Added
- Initial release of Redis Emulator gem
- Redis-compatible client interface (`Redis::Emulator::Client`)
- Integration with Rails Solid Cache as persistence layer
- Support for basic Redis commands:
  - Key operations: GET, SET, DEL, EXISTS, EXPIRE, TTL
  - String operations: INCR, DECR, INCRBY, DECRBY, MGET, MSET, SETEX, SETNX, GETSET, APPEND, STRLEN
  - Server operations: FLUSHDB, PING, INFO
  - Connection operations: CLOSE, CONNECTED?
  - Transaction operations: PIPELINED, MULTI (simplified)
- Configuration system for custom cache stores
- Rails generator for easy installation (`rails generate redis:emulator:install`)
- Comprehensive RSpec test suite (35 examples)
- Comprehensive Cucumber test suite (5 scenarios, 20 steps)
- Full documentation including README and architecture diagrams
- MIT License

### Known Limitations
- TTL command always returns -1 for existing keys (Solid Cache limitation)
- KEYS command not implemented (Solid Cache limitation)
- Only string operations supported (no lists, sets, hashes, sorted sets)
- Pub/Sub not supported
- Transactions are simplified without true atomicity guarantees

[0.1.0]: https://github.com/example/redis-emulator/releases/tag/v0.1.0
