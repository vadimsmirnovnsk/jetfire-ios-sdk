import Foundation
import UserNotifications
import UIKit
import VNBase

public class Jetfire {

	public static let standard = Jetfire()

	public var cover: CoverStyle = .delo()
	public let storiesConfig = StoriesConfig()
	public let snapsConfig = StoryTypesConfig()

	private var userUuid = UUID().uuidString
	private var isStarted = false

	private(set) lazy var router = FeaturingRouter(container: self)
    private lazy var container: JetfireContainer = {
        JetfireContainer(router: router)
    }()

    public init() {
    }

	public func start(with userUuid: String) {
		self.isStarted = true
		self.userUuid = userUuid
        self.container.jetfireMain.start()
	}

	public func trackStart(feature: String) {
		guard self.isStarted else { return }
        self.container.featuring.trackStart(feature: feature)
	}

	public func trackFinish(feature: String) {
		guard self.isStarted else { return }
        self.container.featuring.trackFinish(feature: feature)
	}

	public func updatePushStatus(granted: Bool) {
		guard self.isStarted else { return }
        self.container.featuring.updatePushStatus(granted: granted)
	}

	public func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse
	) {
        self.container.featuring.userNotificationCenter(center, didReceive: response)
	}

	public func storiesView() -> UIView {
        let vm = ContentStoriesVM(storiesService: self.container.storiesService)
		let view = ContentStoriesView()
		view.viewModel = vm
		return view
	}

	/// Container
	internal func toaster(style: ToasterView.Style, visualStyle: ToasterView.VisualStyle) -> ToasterView {
		return ToasterView(style: style, visualStyle: visualStyle)
	}

}
