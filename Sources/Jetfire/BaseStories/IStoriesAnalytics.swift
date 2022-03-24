import VNBase
import VNEssential
import VNHandlers
import UIKit

/// BaseStories — это базовая логика сториз: карусель кругляшей и открывающиеся по тапу в них сториз с пустыми снапами.
/// Трекинг показа историй в аналитику, прокручивания снапов и т.д.
/// Типы историй и снапов в отдельной папочке — StoryTypes

internal protocol IStoriesAnalytics: AnyObject {

	// Firebase Story
	func trackStoryDidStartShow(storyId: String, campaignId: Int64)
	func trackStoryDidFinishShow(storyId: String, campaignId: Int64)
	func trackStorySnapDidShow(storyId: String, index: Int, campaignId: Int64)
	func trackStoryDidTapButton(storyId: String, index: Int, buttonTitle: String, campaignId: Int64)

}
