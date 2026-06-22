class CommandPalette::PageDirectory
  Entry = Struct.new(:label, :path, :icon, keyword_init: true)

  class << self
    def search(query)
      return [] if query.blank?

      entries.select { |entry| entry.label.downcase.include?(query.downcase) }
    end

    private
      def entries
        routes = Rails.application.routes.url_helpers

        [
          Entry.new(label: I18n.t("UI.command_palette.pages.accounts"), path: routes.accounts_path, icon: "layers"),
          Entry.new(label: I18n.t("UI.command_palette.pages.transactions"), path: routes.transactions_path, icon: "credit-card"),
          Entry.new(label: I18n.t("UI.command_palette.pages.budgets"), path: routes.budgets_path, icon: "map"),
          Entry.new(label: I18n.t("UI.command_palette.pages.reports"), path: routes.reports_path, icon: "bar-chart-2"),
          Entry.new(label: I18n.t("UI.command_palette.pages.goals"), path: routes.goals_path, icon: "target"),
          Entry.new(label: I18n.t("UI.command_palette.pages.assistant"), path: routes.chats_path, icon: "sparkles"),
          Entry.new(label: I18n.t("UI.command_palette.pages.categories"), path: routes.categories_path, icon: "shapes"),
          Entry.new(label: I18n.t("UI.command_palette.pages.tags"), path: routes.tags_path, icon: "tag"),
          Entry.new(label: I18n.t("UI.command_palette.pages.rules"), path: routes.rules_path, icon: "list-checks"),
          Entry.new(label: I18n.t("UI.command_palette.pages.merchants"), path: routes.family_merchants_path, icon: "store"),
          Entry.new(label: I18n.t("UI.command_palette.pages.imports"), path: routes.imports_path, icon: "upload"),
          Entry.new(label: I18n.t("UI.command_palette.pages.preferences"), path: routes.settings_preferences_path, icon: "settings"),
          Entry.new(label: I18n.t("UI.command_palette.pages.appearance"), path: routes.settings_appearance_path, icon: "palette"),
          Entry.new(label: I18n.t("UI.command_palette.pages.security"), path: routes.settings_security_path, icon: "shield")
        ].freeze
      end
  end
end
