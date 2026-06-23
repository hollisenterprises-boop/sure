class CommandPaletteController < ApplicationController
  RESULT_LIMIT = 5

  def show
    query = params[:q].to_s.strip

    if query.blank?
      @accounts = []
      @entries = []
      @pages = []
      return render layout: false
    end

    @accounts = Current.family.accounts
                        .visible
                        .where("accounts.name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%")
                        .alphabetically
                        .limit(RESULT_LIMIT)

    @entries = EntrySearch.apply_search_filter(Current.family.entries.joins(:account), query)
                          .includes(:account)
                          .reverse_chronological
                          .limit(RESULT_LIMIT)

    @pages = CommandPalette::PageDirectory.search(query).first(RESULT_LIMIT)

    render layout: false
  end
end
