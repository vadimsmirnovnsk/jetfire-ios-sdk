import UIKit

/// BaseStories — это базовая логика сториз: карусель кругляшей и открывающиеся по тапу в них сториз с пустыми снапами.
/// Трекинг показа историй в аналитику, прокручивания снапов и т.д.
/// Типы историй и снапов в отдельной папочке — StoryTypes

internal protocol IStoriesAnalytics: AnyObject {

	func trackStoryDidStartShow(storyId: String, campaignId: Int64)
	func trackStoryDidFinishShow(storyId: String, campaignId: Int64)
	func trackStorySnapDidShow(storyId: String, index: Int, campaignId: Int64)
	func trackStoryDidTapButton(storyId: String, index: Int, buttonTitle: String, campaignId: Int64)
	func trackStoryDidClose(storyId: String, index: Int, campaignId: Int64)

	func trackToastDidShow(campaignId: Int64)
	func trackToastDidHide(campaignId: Int64)
	func trackToastDidAutohide(campaignId: Int64, time: TimeInterval)
	func trackToastDidTap(campaignId: Int64)

	func trackPushDidShow(campaignId: Int64)
	func trackPushDidTap(campaignId: Int64)

}
