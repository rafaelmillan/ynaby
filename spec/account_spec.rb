RSpec.describe Ynaby::Account do
  let(:user) { Ynaby::User.new(API_TOKEN) }
  let(:budget) { VCR.use_cassette("budgets") { user.budget(BUDGET_ID) } }
  let(:account) { VCR.use_cassette("account") { budget.account(ACCOUNT_ID) } }

  describe "#transactions" do
    context "when date is nil" do
      it "returns all transactions" do
        VCR.use_cassette("transactions_without_date") do
          transactions = account.transactions

          expect(transactions.count).to eq(4)
          expect(transactions.first).to be_a(Ynaby::Transaction)
        end
      end
    end

    context "when date is set" do
      it "returns transactions since the given date" do
        VCR.use_cassette("transactions_with_date") do
          transactions = account.transactions(since: Date.new(2018, 9, 28))

          expect(transactions.count).to eq(2)
        end
      end
    end
  end

  describe "#bulk_upload_transactions" do
    let(:account_for_upload) do
      VCR.use_cassette("account_for_upload") { budget.account(ACCOUNT_FOR_UPLOAD_ID) }
    end

    let(:transaction1) do
      Ynaby::Transaction.new(
        date: Date.new(2018, 9, 15),
        amount: -10000,
        payee_name: "Jerry Seinfeld",
        account: account_for_upload,
        import_id: import_id_1
      )
    end

    let(:transaction2) do
      Ynaby::Transaction.new(
        date: Date.new(2018, 9, 15),
        amount: 50000,
        payee_name: "George Constanza",
        account: account_for_upload,
        import_id: import_id_2
      )
    end

    let(:import_id_1) { nil }
    let(:import_id_2) { nil }

    let(:transactions) { [transaction1, transaction2] }

    it "uploads the transactions" do
      VCR.use_cassette("bulk_upload") do
        expected_body = {
          transactions: [
            transaction1.upload_hash,
            transaction2.upload_hash
          ]
        }

        expect_any_instance_of(YnabApi::TransactionsApi)
          .to receive(:bulk_create_transactions)
          .with(BUDGET_ID, expected_body)
          .and_call_original

        result = account.bulk_upload_transactions(transactions)

        expect(result).to eq(new: 2, updated: 0)
      end
    end

    context "when the transaction have already been imported" do
      let(:import_id_1) { "ynaby:-10000:2018-09-15:1" }
      let(:import_id_2) { "ynaby:50000:2018-09-15:1" }

      it "updates the transactions" do
        VCR.use_cassette("bulk_upload_with_duplicate") do
          expect(transaction1).to receive(:update)
          expect(transaction2).to receive(:update)

          result = account.bulk_upload_transactions(transactions)

          expect(result).to eq(new: 0, updated: 2)
        end
      end
    end

    context "when there is nothing to upload" do
      it "returns zero results" do
        expected_result = { new: 0, updated: 0 }

        expect(account.bulk_upload_transactions(nil)).to eq(expected_result)
        expect(account.bulk_upload_transactions([])).to eq(expected_result)
      end
    end
  end

  describe "#transaction" do
    it "returns a transaction" do
      VCR.use_cassette("transaction") do
        expect(account.transaction(TRANSACTION_ID)).to be_a(Ynaby::Transaction)
      end
    end
  end

  describe ".parse" do
    it "returns an account object with all the attributes" do
      VCR.use_cassette("account") do
        raw_account = user.ynab_client.accounts.get_account_by_id(BUDGET_ID, ACCOUNT_ID).data.account
        parsed_account = Ynaby::Account.parse(object: raw_account, budget: budget)

        expect(parsed_account.id).to eq(ACCOUNT_ID)
        expect(parsed_account.name).to eq("My Checking Account")
        expect(parsed_account.type).to eq("checking")
        expect(parsed_account.on_budget).to eq(true)
        expect(parsed_account.closed).to eq(false)
        expect(parsed_account.note).to eq("Yada, yada")
        expect(parsed_account.balance).to eq(400000)
        expect(parsed_account.cleared_balance).to eq(-600000)
        expect(parsed_account.uncleared_balance).to eq(1000000)
        expect(parsed_account.budget).to eq(budget)
      end
    end
  end

  describe "#api_token" do
    it { expect(account.api_token).to eq(API_TOKEN) }
  end
end
