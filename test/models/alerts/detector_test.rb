require "test_helper"

class Alerts::DetectorTest < ActiveSupport::TestCase
  setup do
    @family = families(:dylan_family)
  end

  test "flags visible asset accounts below the low balance threshold" do
    low_account = Account.create!(
      family: @family,
      name: "Almost Empty #{Time.now.to_f}",
      balance: 42,
      currency: "USD",
      classification: "asset",
      accountable: Depository.new,
      status: "active"
    )

    alerts = Alerts::Detector.for(@family)

    assert alerts.any? { |a| a.title.include?(low_account.name) }
  end

  test "does not flag liability accounts even with a low balance" do
    Account.create!(
      family: @family,
      name: "Low Credit Card #{Time.now.to_f}",
      balance: 5,
      currency: "USD",
      classification: "liability",
      accountable: CreditCard.new,
      status: "active"
    )

    alerts = Alerts::Detector.for(@family)

    assert alerts.none? { |a| a.title.include?("Low Credit Card") }
  end

  test "does not flag accounts above the threshold" do
    healthy_account = Account.create!(
      family: @family,
      name: "Healthy Account #{Time.now.to_f}",
      balance: 5000,
      currency: "USD",
      classification: "asset",
      accountable: Depository.new,
      status: "active"
    )

    alerts = Alerts::Detector.for(@family)

    assert alerts.none? { |a| a.title.include?(healthy_account.name) }
  end

  test "flags budget categories that are over spent" do
    budget = budgets(:one)
    category = Category.create!(name: "Test Overage #{Time.now.to_f}", family: @family)
    budget_category = BudgetCategory.create!(budget: budget, category: category, budgeted_spending: 100, currency: "USD")

    BudgetCategory.any_instance.stubs(:percent_of_budget_spent).returns(150)

    alerts = Alerts::Detector.for(@family)

    assert alerts.any? { |a| a.title.include?(budget_category.name) }
  end

  test "does not flag budget categories within budget" do
    budget = budgets(:one)
    category = Category.create!(name: "Test On Track #{Time.now.to_f}", family: @family)
    BudgetCategory.create!(budget: budget, category: category, budgeted_spending: 100, currency: "USD")

    BudgetCategory.any_instance.stubs(:percent_of_budget_spent).returns(50)

    alerts = Alerts::Detector.for(@family)

    assert alerts.none? { |a| a.title.include?("Test On Track") }
  end
end
