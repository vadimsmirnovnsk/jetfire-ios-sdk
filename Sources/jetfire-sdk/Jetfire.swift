import Foundation
import UserNotifications
import UIKit
import VNBase

public class Jetfire {

	public static let standard = Jetfire()

	public var cover: CoverStyle = .delo()
	public let storiesConfig = StoriesConfig()
	public let snapsConfig = StoryTypesConfig()

	private var isStarted = false

	private(set) lazy var router = FeaturingRouter(container: self)
    private lazy var container: JetfireContainer = {
        JetfireContainer(router: router)
    }()

    private init() {}

	public func start() {
		self.isStarted = true
        self.container.jetfireMain.start()
	}

	public func storiesView() -> UIView {
        let vm = ContentStoriesVM(storiesService: self.container.storiesService)
		let view = ContentStoriesView()
		view.viewModel = vm
		return view
	}

    func toaster(style: ToasterView.Style, visualStyle: ToasterView.VisualStyle) -> ToasterView {
		return ToasterView(style: style, visualStyle: visualStyle)
	}
}

// MARK: - Analytics

public extension Jetfire {

    func trackStart(feature: String) {
        guard self.isStarted else { return }
        self.container.featuring.trackStart(feature: feature)
    }

    func trackFinish(feature: String) {
        guard self.isStarted else { return }
        self.container.featuring.trackFinish(feature: feature)
    }

    func logEvent(_ name: String) {
        guard self.isStarted else { return }
        self.container.externalAnalyticsService.logEvent(name)
    }

    func setUserProperty(_ value: Any, forName name: String) {
        guard self.isStarted else { return }
        self.container.externalAnalyticsService.setUserProperty(value, forName: name)
    }

    func removeUserProperty(forName name: String) {
        guard self.isStarted else { return }
        self.container.externalAnalyticsService.removeUserProperty(forName: name)
    }

    func setSessionProperty(_ value: Any, forName name: String) {
        guard self.isStarted else { return }
        self.container.externalAnalyticsService.setSessionProperty(value, forName: name)
    }

    func removeSessionProperty(forName name: String) {
        guard self.isStarted else { return }
        self.container.externalAnalyticsService.removeSessionProperty(forName: name)
    }
}
