require "test_helper"

class ChatSuggestions::GeneratorTest < ActiveSupport::TestCase
  test "surfaces the first alert as a suggestion" do
    alert = Alerts::Detector::Alert.new(severity: "warning", title: "Low balance: Test", body: "test", path: "/", icon: "alert-triangle")

    suggestions = ChatSuggestions::Generator.for(alerts: [ alert ])

    assert suggestions.any? { |s| s.text == "Low balance: Test" }
  end

  test "falls back to default suggestions when there are no alerts" do
    suggestions = ChatSuggestions::Generator.for(alerts: [])

    assert suggestions.any?
  end

  test "caps suggestions at three" do
    alert = Alerts::Detector::Alert.new(severity: "warning", title: "Test Alert", body: "test", path: "/", icon: "alert-triangle")

    suggestions = ChatSuggestions::Generator.for(alerts: [ alert ])

    assert suggestions.size <= 3
  end
end
