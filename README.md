# Ynaby

Unofficial wrapper gem of the [YNAB Ruby SDK](https://github.com/ynab/ynab-sdk-ruby) for modifying and creating transactions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ynaby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ynaby

## Usage

```ruby
user = Ynaby::User.new("my_api_token")

user.budgets # All budgets
budget = user.budget("budget_id") # Find budget

budget.accounts # All accounts
account = budget.account("account_id") # Find account

account.transactions # All transactions
account.transaction(since: Date.new(2018, 9, 28)) # Transactions since date
transaction = account.transaction("transaction_id") # Find transaction

transaction.memo = "New memo"
transaction.update # Updates the transaction

new_transaction = Ynaby::Transaction.new(
  date: Date.new(2018, 9, 15),
  amount: -10000,
  payee_name: "Jerry Seinfeld",
  account: account
)
new_transaction.upload # Creates a new transaction

account.bulk_upload_transactions([new_transaction]) # Bulk upload
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rafaelmillan/ynaby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
