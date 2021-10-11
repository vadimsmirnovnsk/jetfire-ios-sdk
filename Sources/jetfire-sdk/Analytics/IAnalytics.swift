internal protocol IAnalytics: AnyObject {

	func track(_ event: AnalyticsEventBuilder)
	func trackUserProperties(_ event: AnalyticsEventBuilder)

}
