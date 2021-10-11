import Foundation

internal class Anl {

	static private var service: Anl!

	private let analytics: [IAnalytics]
	private let queue: DispatchQueue

	static public func set(service: Anl) {
		if self.service == nil {
			self.service = service
		} else {
			assert(false, "There is already shared service")
		}
	}

	internal static func track(_ closure: (_ event: IEventBuilder) -> Void) {
		let builder = AnalyticsEventBuilder()
		closure(builder)
		Anl.service.track(builder)
	}

	internal static func trackUserProperties(_ closure: (_ event: IEventBuilder) -> Void) {
		let builder = AnalyticsEventBuilder()
		closure(builder)
		Anl.service.trackUserProperties(builder, replace: false)
	}

	internal init(analytics: [IAnalytics]) {
		self.analytics = analytics
		self.queue = DispatchQueue(label: "xyz.steelhoss.firetest.analytics")
	}

	public func configure() { }

	private func track(_ event: AnalyticsEventBuilder) {
		if event.params.isEmpty {
			print("Analytics (event: \(event.name ?? "⛔️ none"))")
		} else {
			print("Analytics (event: \(event.name ?? "none")), (params: \(event.params))")
		}

		self.queue.async { [weak self] in
			self?.analytics.forEach { $0.track(event) }
		}
	}

	private func trackUserProperties(_ event: AnalyticsEventBuilder, replace: Bool = false) {
		guard !event.params.isEmpty else { return }

		print("Analytics trackUserProperties (params: \(event.params))")

		self.queue.async { [weak self] in
			self?.analytics.forEach { $0.trackUserProperties(event) }
		}
	}

}
