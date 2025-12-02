# Load redis gem first to ensure Redis class exists
begin
  require 'redis'
rescue LoadError
  # Redis gem not yet available during gemspec evaluation
end

require_relative "lib/redis/emulator/version"

Gem::Specification.new do |spec|
  spec.name        = "redis-emulator"
  spec.version     = Redis::Emulator::VERSION
  spec.authors     = ["Redis Emulator Contributors"]
  spec.email       = ["redis-emulator@example.com"]
  spec.homepage    = "https://github.com/example/redis-emulator"
  spec.summary     = "Redis emulation using Rails Solid Cache"
  spec.description = "A Rails engine gem that provides Redis emulation using Rails Solid Cache as the persistence layer, compatible with redis-rb."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/example/redis-emulator"
  spec.metadata["changelog_uri"] = "https://github.com/example/redis-emulator/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "redis", "~> 4.0"
  spec.add_dependency "solid_cache", "~> 1.0"
end
