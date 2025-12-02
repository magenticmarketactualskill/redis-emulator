class Redis
  module Emulator
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        desc "Creates a Redis Emulator initializer"

        def copy_initializer
          template "redis_emulator.rb", "config/initializers/redis_emulator.rb"
        end

        def show_readme
          readme "README" if behavior == :invoke
        end
      end
    end
  end
end
