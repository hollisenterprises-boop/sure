require "test_helper"

class Insights::GeneratorTest < ActiveSupport::TestCase
  setup do
    @family = families(:dylan_family)
    @bills = Category.create!(name: "Test Bills #{Time.now.to_f}", family: @family)
    @groceries = Category.create!(name: "Test Groceries #{Time.now.to_f}", family: @family)
  end

  test "flags a category with a significant spending increase" do
    current = [ category_total(@bills, 200) ]
    previous = [ category_total(@bills, 100) ]

    insights = generate(current: current, previous: previous)

    assert insights.any? { |i| i.tone == "warning" && i.text.include?(@bills.name) }
  end

  test "flags a category with a significant spending decrease" do
    current = [ category_total(@bills, 50) ]
    previous = [ category_total(@bills, 200) ]

    insights = generate(current: current, previous: previous)

    assert insights.any? { |i| i.tone == "success" && i.text.include?(@bills.name) }
  end

  test "ignores categories with no comparable previous spending" do
    current = [ category_total(@bills, 200) ]
    previous = []

    insights = generate(current: current, previous: previous)

    assert insights.none? { |i| i.text.include?(@bills.name) }
  end

  test "ignores categories below the minimum comparable amount" do
    current = [ category_total(@bills, 10) ]
    previous = [ category_total(@bills, 1) ]

    insights = generate(current: current, previous: previous)

    assert insights.none? { |i| i.text.include?(@bills.name) }
  end

  test "ignores changes below the significance threshold" do
    current = [ category_total(@bills, 105) ]
    previous = [ category_total(@bills, 100) ]

    insights = generate(current: current, previous: previous)

    assert insights.none? { |i| i.text.include?(@bills.name) }
  end

  test "includes an overall expense trend insight when significant" do
    insights = generate(current: [], previous: [], income_change: 0, expense_change: 25)

    assert insights.any? { |i| i.tone == "warning" && i.icon == "arrow-up-right" }
  end

  test "caps insights at three" do
    many_categories = (1..5).map do |n|
      category = Category.create!(name: "Test Cat #{n} #{Time.now.to_f}", family: @family)
      [ category_total(category, 200), category ]
    end

    current = many_categories.map(&:first)
    previous = many_categories.map { |ct, category| category_total(category, 100) }

    insights = generate(current: current, previous: previous, expense_change: 30)

    assert insights.size <= 3
  end

  private
    def category_total(category, amount)
      IncomeStatement::CategoryTotal.new(category: category, total: amount, currency: @family.currency, weight: 0)
    end

    def generate(current:, previous:, income_change: 0, expense_change: 0)
      Insights::Generator.new(
        current_category_totals: current,
        previous_category_totals: previous,
        income_change: income_change,
        expense_change: expense_change,
        currency: @family.currency
      ).insights
    end
end
