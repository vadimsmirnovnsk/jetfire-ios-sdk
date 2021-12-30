import VNBase
import VNEssential
import VNHandlers
import UIKit

/// Здесь базовая логика сториз — карусель кругляшей и открывающиеся по тапу в них сториз с пустыми снапами.
/// Трекинг показа историй в аналитику, прокручивания снапов и т.д.
/// Типы историй и снапов в отдельной папочке — StoryTypes
public final class StoriesConfig {

	/// [ Base Stories

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
