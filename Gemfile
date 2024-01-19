# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in importmap-cli.gemspec
gemspec

gem 'pry-byebug'
gem 'rake', '~> 13.0'
gem 'rspec', '~> 3.0'

group :development, :test do
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false

  gem 'rubycritic', require: false
end

group :test do
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end
