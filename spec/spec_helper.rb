require "bundler/setup"
require "ynaby"
require "webmock/rspec"
require "vcr"
require "pry"

API_TOKEN = "fake_api_token"
BUDGET_ID = "da64e638-63f0-41fc-97a2-cc7f38c8b034"
ACCOUNT_ID = "c791437c-6660-4e86-b41e-50e70e6ff34d"
ACCOUNT_FOR_UPLOAD_ID = "eccab6f8-2d96-47b2-a19c-4c996a46ae65"
TRANSACTION_ID = "1ca525cb-4462-4687-adab-37796f3fd629"

WebMock.disable_net_connect!

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  config.filter_sensitive_data('<API_TOKEN>') do |interaction|
    interaction.request.headers['Authorization'].first
  end

  config.before_record do |interaction|
    body = JSON.parse(interaction.response.body)
    budgets = body.dig("data", "budgets")

    if budgets
      test_budgets = budgets.select { |budget| budget["name"] == "Ynaby budget" }
      body["data"]["budgets"] = test_budgets
      interaction.response.body = body.to_json
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
