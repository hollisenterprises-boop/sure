require "test_helper"

class CommandPaletteControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:family_admin)
    sign_in @user
  end

  test "blank query renders prompt without querying records" do
    get command_palette_url(q: "")

    assert_response :success
    assert_match(/start typing to search/i, response.body)
  end

  test "matches accounts by name" do
    get command_palette_url(q: "Checking")

    assert_response :success
    assert_match(/Checking Account/, response.body)
  end

  test "matches transactions by name" do
    get command_palette_url(q: "Starbucks")

    assert_response :success
    assert_match(/Starbucks/, response.body)
  end

  test "matches static pages by label" do
    get command_palette_url(q: "Budget")

    assert_response :success
    assert_match(/Budgets/, response.body)
  end

  test "no results renders empty state" do
    get command_palette_url(q: "zzzzznonexistent")

    assert_response :success
    assert_match(/no results found/i, response.body)
  end
end
