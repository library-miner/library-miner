require File.expand_path('../support/github_response_support.rb', __FILE__)

RSpec.configure do |config|
  require 'simplecov'
  require 'webmock/rspec'
  require 'database_cleaner'

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # whitelist api.github.com so test coverage can be reported
  config.after(:suite) do
    WebMock.disable_net_connect!(:allow => 'api.github.com')
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  SimpleCov.start 'rails'
end
