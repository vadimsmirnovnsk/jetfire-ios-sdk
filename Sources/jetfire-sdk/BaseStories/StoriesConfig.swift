import VNBase
import VNEssential
import VNHandlers
import UIKit

/// Здесь базовая логика сториз — карусель кругляшей и открывающиеся по тапу в них сториз с пустыми снапами.
/// Трекинг показа историй в аналитику, прокручивания снапов и т.д.
/// Типы историй и снапов в отдельной папочке — StoryTypes
public final class StoriesConfig {

	/// [ Base Stories
	internal let analytics = StoriesAnalytics()
//	public var externalAnalytics: IStoriesAnalytics? {
//		didSet {
//			self.analytics.externalAnalytics = self.externalAnalytics
//		}
//	}

	/// Story Circle
	var storyCircleBackgroundColor: UIColor = .storiesAlmostWhite
	var storyCircleTextStyle: TextStyle = .system13GraffitBlack
	var storyCircleRingLeftGradientColor: UIColor = .gradientOrange
	var storyCircleRingRightGradientColor: UIColor = .gradientYellow
	var storyCircleCellWidth: CGFloat = 80
	var storyCircleCellHeight: CGFloat = 100
	var storyCircleCellInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
	var storyCircleImageDiameter: CGFloat = 60
	var storyCircleSubstrateDiameter: CGFloat = 68
	var storyCircleSubstrateWidth: CGFloat = 1

	/// Story Browser
	var progressBarTopColor: UIColor = .storiesAlmostWhite
	var progressBarBottomColor: UIColor = .storiesAlmostWhite.withAlphaComponent(0.5)

	var navigationBarTextAttribbutes: [NSAttributedString.Key : Any] = [
		.foregroundColor : UIColor.white,
		.font : UIFont.systemFont(ofSize: 14),
	]
	/// ] Base Stories

	init(analytics: [IAnalytics]) {
		Anl.set(service: Anl(analytics: analytics))
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

	var externalAnalytics: [IStoriesAnalytics] = []

	// Firebase Story and Featuring
	func trackStorySnapDidShow(storyId: String, index: Int) {
		Anl.track {
			$0.name(.jetfire_story_snap_show)
				.param(.jetfire_featuring_id, value: storyId)
				.param(.jetfire_snap_index, value: index)
		}

		self.externalAnalytics.forEach { $0.trackStorySnapDidShow(storyId: storyId, index: index) }
	}

	func trackStoryDidStartShow(storyId: String) {
		Anl.track {
			$0.name(.jetfire_story_start_show)
				.param(.jetfire_featuring_id, value: storyId)
		}

		self.externalAnalytics.forEach { $0.trackStoryDidStartShow(storyId: storyId) }
	}

	func trackStoryDidFinishShow(storyId: String) {
		Anl.track {
			$0.name(.jetfire_story_finish_show)
				.param(.jetfire_featuring_id, value: storyId)
		}

		self.externalAnalytics.forEach { $0.trackStoryDidFinishShow(storyId: storyId) }
	}

	func trackStoryDidTapButton(buttonOrSnapId: String, buttonTitle: String) {
		Anl.track {
			$0.name(.jetfire_story_cta_tap)
				.param(.jetfire_featuring_id, value: buttonOrSnapId)
		}

		self.externalAnalytics.forEach { $0.trackStoryDidTapButton(buttonOrSnapId: buttonOrSnapId, buttonTitle: buttonTitle) }
	}
}

