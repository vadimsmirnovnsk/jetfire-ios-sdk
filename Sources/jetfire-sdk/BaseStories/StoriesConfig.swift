import VNBase
import VNEssential
import VNHandlers
import UIKit

/// Здесь базовая логика сториз — карусель кругляшей и открывающиеся по тапу в них сториз с пустыми снапами.
/// Трекинг показа историй в аналитику, прокручивания снапов и т.д.
/// Типы историй и снапов в отдельной папочке — StoryTypes
public final class StoriesConfig {

	/// [ Base Stories

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

}

internal protocol IStoriesAnalytics: AnyObject {

	// Firebase Story
	func trackStoryDidStartShow(storyId: String, campaignId: Int64)
	func trackStoryDidFinishShow(storyId: String, campaignId: Int64)
	func trackStorySnapDidShow(storyId: String, index: Int, campaignId: Int64)
	func trackStoryDidTapButton(storyId: String, index: Int, buttonTitle: String, campaignId: Int64)

}
