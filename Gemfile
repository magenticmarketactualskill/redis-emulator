source "https://rubygems.org"

# Specify your gem's dependencies in redis-emulator.gemspec.
gemspec

gem "puma"

gem "sqlite3"

gem "propshaft"

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"

# Development and testing dependencies
group :development, :test do
  gem "rspec-rails", "~> 7.0"
  gem "cucumber-rails", "~> 3.0", require: false
  gem "database_cleaner-active_record"
end
