import VNBase
import VNEssential
import VNHandlers
import UIKit

public final class StoriesConfig {

	/// [ Base Stories
	internal let analytics = StoriesAnalytics()
	public var externalAnalytics: IStoriesAnalytics? {
		didSet {
			self.analytics.externalAnalytics = self.externalAnalytics
		}
	}

	/// Story Circle
	var storyCircleBackgroundColor: UIColor = .storiesAlmostWhite
	var storyCircleTextStyle: TextStyle = .system13GraffitBlack
	var storyCircleRingLeftGradientColor: UIColor = .gradientOrange
	var storyCircleRingRightGradientColor: UIColor = .gradientYellow

	/// Story Browser
	var progressBarTopColor: UIColor = .storiesAlmostWhite
	var progressBarBottomColor: UIColor = .storiesAlmostWhite.withAlphaComponent(0.5)

	var navigationBarTextAttribbutes: [NSAttributedString.Key : Any] = [
		.foregroundColor : UIColor.white,
		.font : UIFont.systemFont(ofSize: 14),
	]
	/// ] Base Stories

	/// [ Featuring
//	let featuring: FeaturingService
//	private let featuringManager: FeaturingManager
//	private let featuringStorage: FeaturingStorage
//	private let featuringPushService: FeaturingPushService
	/// ] Featuring

	init() {
//		Anl.set(service: Anl(analytics: [ FirebaseAnalytics() ]))
//
//		self.processTargetService = ProcessTargetService(application: UIApplication.shared)
//		self.storage = StoriesStorage(processTargetService: self.processTargetService, router: self.router)
//		self.storiesService = StoriesService(router: self.router, api: self.apiService, storage: self.storage, processTargetService: self.processTargetService, ud: self.ud)

		/// Featuring
//		self.featuringStorage = FeaturingStorage(
//			storiesService: self.storiesService,
//			api: self.apiService,
//			userId: UUID().uuidString
//		)
//		self.featuringManager = FeaturingManager(ud: self.ud, storage: self.featuringStorage)
//		self.featuringPushService = FeaturingPushService(ud: self.ud)
//		self.featuring = FeaturingService(
//			manager: self.featuringManager,
//			storiesService: self.storiesService,
//			pushService: self.featuringPushService
//		)
	}

}

public protocol IStoriesAnalytics: AnyObject {

	// Firebase Story
	func trackStoryDidStartShow(storyId: String)
	func trackStoryDidFinishShow(storyId: String)
	func trackStorySnapDidShow(storyId: String, index: Int)
	func trackStoryDidTapButton(buttonOrSnapId: String, buttonTitle: String)
}

internal class StoriesAnalytics: IStoriesAnalytics {

	var externalAnalytics: IStoriesAnalytics?

	// Firebase Story and Featuring
	func trackStorySnapDidShow(storyId: String, index: Int) {
//		Anl.track {
//			$0.name(.firetest_story_snap_show)
//				.param(.firetest_featuring_id, value: storyId)
//				.param(.firetest_snap_index, value: index)
//		}

		self.externalAnalytics?.trackStorySnapDidShow(storyId: storyId, index: index)
	}

	func trackStoryDidStartShow(storyId: String) {
//		Anl.track {
//			$0.name(.firetest_story_start_show)
//				.param(.firetest_featuring_id, value: storyId)
//		}

		self.externalAnalytics?.trackStoryDidStartShow(storyId: storyId)
	}

	func trackStoryDidFinishShow(storyId: String) {
//		Anl.track {
//			$0.name(.firetest_story_finish_show)
//				.param(.firetest_featuring_id, value: storyId)
//		}

		self.externalAnalytics?.trackStoryDidFinishShow(storyId: storyId)
	}

	func trackStoryDidTapButton(buttonOrSnapId: String, buttonTitle: String) {
//		Anl.track {
//			$0.name(.firetest_story_cta_tap)
//				.param(.firetest_featuring_id, value: buttonOrSnapId)
//		}

		self.externalAnalytics?.trackStoryDidTapButton(buttonOrSnapId: buttonOrSnapId, buttonTitle: buttonTitle)
	}
}

