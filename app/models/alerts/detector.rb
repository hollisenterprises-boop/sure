class Alerts::Detector
  Alert = Struct.new(:severity, :title, :body, :path, :icon, keyword_init: true)

  LOW_BALANCE_THRESHOLD = 100

  class << self
    def for(family)
      new(family).alerts
    end
  end

  def initialize(family)
    @family = family
  end

  def alerts
    low_balance_alerts + budget_overage_alerts
  end

  private
    attr_reader :family

    def low_balance_alerts
      family.accounts.visible.assets.where("accounts.balance < ?", LOW_BALANCE_THRESHOLD).map do |account|
        Alert.new(
          severity: "warning",
          title: I18n.t("UI.alerts.low_balance.title", account: account.name),
          body: I18n.t("UI.alerts.low_balance.body", balance: Money.new(account.balance, account.currency).format),
          path: Rails.application.routes.url_helpers.account_path(account),
          icon: "alert-triangle"
        )
      end
    end

    def budget_overage_alerts
      period_start, _period_end = Budget.period_for(Date.current, family: family)
      budget = family.budgets.find_by(start_date: period_start)
      return [] unless budget

      budget.budget_categories.select { |bc| bc.budgeted_spending.to_f > 0 && bc.percent_of_budget_spent > 100 }.map do |bc|
        Alert.new(
          severity: "warning",
          title: I18n.t("UI.alerts.budget_overage.title", category: bc.name),
          body: I18n.t("UI.alerts.budget_overage.body", percent: bc.percent_of_budget_spent.round),
          path: Rails.application.routes.url_helpers.budget_path(budget),
          icon: "trending-up"
        )
      end
    end
end
