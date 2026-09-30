source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

# Manual JWT encode/decode for authentication (educational choice, see README)
gem "jwt"

# Authorization policies scoped by team role
gem "pundit"

# Fast, explicit JSON serialization
gem "blueprinter"

# Pagination (pinned to the 9.x classic Backend/Frontend API — the 43.x
# release is a from-scratch rewrite with a different, less documented API)
gem "pagy", "~> 9.4"

# Postgres-backed background jobs (no Redis needed) for async notifications
gem "solid_queue"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Testing framework
  gem "rspec-rails"

  # Concise matchers for common model validations/associations
  gem "shoulda-matchers"

  # Matchers for testing Pundit policies (permit_action/forbid_action)
  gem "pundit-matchers"

  # Test data factories
  gem "factory_bot_rails"

  # Fake data generator for factories/seeds
  gem "faker"
end
