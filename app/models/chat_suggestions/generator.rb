class ChatSuggestions::Generator
  Suggestion = Struct.new(:icon, :text, :prompt, keyword_init: true)

  MAX_SUGGESTIONS = 3

  def initialize(alerts:)
    @alerts = alerts
  end

  def self.for(alerts:)
    new(alerts: alerts).suggestions
  end

  def suggestions
    [ alert_suggestion, *default_suggestions ].compact.first(MAX_SUGGESTIONS)
  end

  private
    attr_reader :alerts

    def alert_suggestion
      alert = alerts.first
      return nil unless alert

      Suggestion.new(
        icon: alert.icon,
        text: alert.title,
        prompt: I18n.t("UI.chat_suggestions.alert_prompt", alert_title: alert.title)
      )
    end

    def default_suggestions
      [
        Suggestion.new(
          icon: "wallet-minimal",
          text: I18n.t("UI.chat_suggestions.spending_insights"),
          prompt: I18n.t("UI.chat_suggestions.spending_insights")
        ),
        Suggestion.new(
          icon: "chart-area",
          text: I18n.t("UI.chat_suggestions.evaluate_portfolio"),
          prompt: I18n.t("UI.chat_suggestions.evaluate_portfolio")
        ),
        Suggestion.new(
          icon: "piggy-bank",
          text: I18n.t("UI.chat_suggestions.save_money"),
          prompt: I18n.t("UI.chat_suggestions.save_money")
        )
      ]
    end
end
