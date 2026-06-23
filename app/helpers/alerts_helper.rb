module AlertsHelper
  def current_family_alerts
    @current_family_alerts ||= Alerts::Detector.for(Current.family)
  end
end
