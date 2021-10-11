//import FirebaseAnalytics
//
//final internal class FirebaseAnalytics: IAnalytics {
//
//	internal func track(_ event: AnalyticsEventBuilder) {
//		guard let name = event.name else { return }
//
//		Analytics.logEvent(name, parameters: event.params)
//	}
//
//	internal func trackUserProperties(_ event: AnalyticsEventBuilder) {
//		guard !event.params.isEmpty else { return }
//
//		event.params.forEach {
//			Analytics.setUserProperty(String(describing: $0.value), forName: $0.key)
//		}
//	}
//
//}

