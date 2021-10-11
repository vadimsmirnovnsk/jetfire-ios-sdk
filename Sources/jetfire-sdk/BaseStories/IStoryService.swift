public protocol IStoryService: AnyObject {

	func isRead(story: IStory) -> Bool
	func markRead(story: IStory)
	func show(story: BaseStory)
	func show(story: BaseStory, in stories: [BaseStory])
	func resortStories()

}
