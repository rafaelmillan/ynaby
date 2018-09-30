RSpec.describe Ynaby::User do
  let(:user) { Ynaby::User.new(API_TOKEN) }

  describe "#budgets" do
    it "returns an array of budgets" do
      VCR.use_cassette("budgets") do
        expect(user.budgets.first).to be_a(Ynaby::Budget)
      end
    end
  end

  describe "#budget" do
    it "returns a specific budget" do
      VCR.use_cassette("budgets") do
        expect(user.budget(BUDGET_ID)).to be_a(Ynaby::Budget)
      end
    end
  end
end
