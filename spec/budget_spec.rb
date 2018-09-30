RSpec.describe Ynaby::Budget do
  let(:user) { Ynaby::User.new(API_TOKEN) }
  let(:budget) { VCR.use_cassette("budgets") { user.budget(BUDGET_ID) } }

  describe "#accounts" do
    it "returns an array of accounts" do
      VCR.use_cassette("accounts") do
        expect(budget.accounts.first).to be_a(Ynaby::Account)
      end
    end
  end

  describe "#account" do
    it "returns a specific account" do
      VCR.use_cassette("account") do
        expect(budget.account(ACCOUNT_ID)).to be_a(Ynaby::Account)
      end
    end
  end

  describe "#currency_code" do
    it "returns the ISO currency code" do
      expect(budget.currency_code).to eq("EUR")
    end
  end

  describe ".parse" do
    it "returns a budget object with all the attributes" do
      VCR.use_cassette("budgets") do
        raw_budget = user.ynab_client.budgets.get_budgets.data.budgets.first
        parsed_budget = Ynaby::Budget.parse(raw_budget, user)

        expect(parsed_budget).to be_a(Ynaby::Budget)
        expect(parsed_budget.id).to eq(BUDGET_ID)
        expect(parsed_budget.name).to eq("Ynaby budget")
        expect(parsed_budget.last_modified_on).to be_a(DateTime)
        expect(parsed_budget.date_format).to eq({ format: "DD/MM/YYYY" })
        expect(parsed_budget.currency_format).to include({ iso_code: "EUR" })
        expect(parsed_budget.user).to eq(user)
      end
    end
  end

  describe "#api_token" do
    it { expect(budget.api_token).to eq(API_TOKEN) }
  end
end
