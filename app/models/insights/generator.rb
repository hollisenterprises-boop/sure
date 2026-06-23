class Insights::Generator
  Insight = Struct.new(:tone, :icon, :text, keyword_init: true)

  MIN_COMPARABLE_AMOUNT = 20
  SIGNIFICANT_CHANGE_PERCENT = 15

  def initialize(current_category_totals:, previous_category_totals:, income_change:, expense_change:, currency:)
    @current_category_totals = current_category_totals
    @previous_category_totals = previous_category_totals
    @income_change = income_change
    @expense_change = expense_change
    @currency = currency
  end

  def insights
    [
      category_increase_insight,
      category_decrease_insight,
      overall_expense_insight
    ].compact.first(3)
  end

  private
    attr_reader :income_change, :expense_change, :currency

    def category_changes
      @category_changes ||= begin
        previous_by_category = @previous_category_totals.index_by { |ct| ct.category.id }

        @current_category_totals.filter_map do |ct|
          next if ct.category.subcategory?

          previous = previous_by_category[ct.category.id]
          previous_total = previous&.total.to_f
          next if previous_total < MIN_COMPARABLE_AMOUNT

          percent = ((ct.total.to_f - previous_total) / previous_total) * 100
          { category: ct.category, current_total: ct.total, percent: percent }
        end
      end
    end

    def category_increase_insight
      change = category_changes.select { |c| c[:percent] >= SIGNIFICANT_CHANGE_PERCENT }.max_by { |c| c[:percent] }
      return nil unless change

      Insight.new(
        tone: "warning",
        icon: "trending-up",
        text: I18n.t("UI.insights.category_increase",
          category: change[:category].name,
          percent: change[:percent].round,
          amount: Money.new(change[:current_total], currency).format)
      )
    end

    def category_decrease_insight
      change = category_changes.select { |c| c[:percent] <= -SIGNIFICANT_CHANGE_PERCENT }.min_by { |c| c[:percent] }
      return nil unless change

      Insight.new(
        tone: "success",
        icon: "trending-down",
        text: I18n.t("UI.insights.category_decrease",
          category: change[:category].name,
          percent: change[:percent].abs.round,
          amount: Money.new(change[:current_total], currency).format)
      )
    end

    def overall_expense_insight
      return nil if expense_change.nil? || expense_change.abs < SIGNIFICANT_CHANGE_PERCENT

      if expense_change > 0
        Insight.new(
          tone: "warning",
          icon: "arrow-up-right",
          text: I18n.t("UI.insights.overall_expense_increase", percent: expense_change.round)
        )
      else
        Insight.new(
          tone: "success",
          icon: "arrow-down-right",
          text: I18n.t("UI.insights.overall_expense_decrease", percent: expense_change.abs.round)
        )
      end
    end
end
