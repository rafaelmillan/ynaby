require "securerandom"

RSpec.describe Ynaby::Transaction do
  let(:user) { Ynaby::User.new(API_TOKEN) }
  let(:budget) { VCR.use_cassette("budgets") { user.budget(BUDGET_ID) } }
  let(:account) { VCR.use_cassette("account") { budget.account(ACCOUNT_ID) } }
  let(:transaction) { VCR.use_cassette("transaction") { account.transaction(TRANSACTION_ID) } }

  describe "#upload" do
    it "uploads the transaction" do
      VCR.use_cassette("transaction_upload") do
        uploads_account = VCR.use_cassette("account_for_upload") { budget.account(ACCOUNT_FOR_UPLOAD_ID) }

        transaction = Ynaby::Transaction.new(
          date: Date.new(2018, 9, 15),
          amount: -10000,
          payee_name: "Jerry Seinfeld",
          account: uploads_account
        )

        expected_body = { transaction: transaction.upload_hash }

        expect_any_instance_of(YnabApi::TransactionsApi)
          .to receive(:create_transaction)
          .with(BUDGET_ID, expected_body)
          .and_call_original

        result = transaction.upload

        expect(result).to be_a(Ynaby::Transaction)
      end
    end
  end

  describe "#upload_hash" do
    it "generates a hash with the correct values" do
      transaction.memo = SecureRandom.hex(60)

      hash = transaction.upload_hash

      expect(hash[:account_id]).to eq (ACCOUNT_ID)
      expect(hash[:date]).to eq ("2018-09-28")
      expect(hash[:amount]).to eq (-100000)
      expect(hash[:payee_name]).to eq ("Supermarket")
      expect(hash[:import_id]).to eq (nil)
      expect(hash[:payee_id]).to eq (nil)
      expect(hash[:memo].length).to eq (50)
    end
  end

  describe "#update" do
    it "updates the transaction" do
      VCR.use_cassette("transaction_update") do
        expected_body = { transaction: transaction.upload_hash }

        expect_any_instance_of(YnabApi::TransactionsApi)
          .to receive(:update_transaction)
          .with(BUDGET_ID, TRANSACTION_ID, expected_body)
          .and_call_original

        result = transaction.update

        expect(result).to be_a(Ynaby::Transaction)
      end
    end
  end

  describe ".parse" do
    it "returns a transaction object with all the attributes" do
      VCR.use_cassette("transaction") do
        raw_transaction = user.ynab_client.transactions.get_transactions_by_id(BUDGET_ID, TRANSACTION_ID).data.transaction
        parsed_transaction = Ynaby::Transaction.parse(object: raw_transaction, account: account)

        expect(parsed_transaction.id).to eq(TRANSACTION_ID)
        expect(parsed_transaction.date).to eq(Date.parse("2018-09-28"))
        expect(parsed_transaction.amount).to eq(-100000)
        expect(parsed_transaction.memo).to eq("Food")
        expect(parsed_transaction.cleared).to eq("cleared")
        expect(parsed_transaction.approved).to eq(true)
        expect(parsed_transaction.flag_color).to eq(nil)
        expect(parsed_transaction.payee_id).to eq("dd836216-66a4-45e0-b63b-dc3df0baed86")
        expect(parsed_transaction.category_id).to eq("ee5a8690-45e6-49d3-af51-72ea104389e3")
        expect(parsed_transaction.transfer_account_id).to eq(nil)
        expect(parsed_transaction.import_id).to eq(nil)
        expect(parsed_transaction.account_name).to eq("My Checking Account")
        expect(parsed_transaction.payee_name).to eq("Supermarket")
        expect(parsed_transaction.category_name).to eq("Groceries")
        expect(parsed_transaction.account).to eq(account)
      end
    end
  end
end
