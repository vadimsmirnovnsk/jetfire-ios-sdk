typealias StoriesBlock = ([BaseStory]) -> Void

protocol IStoriesStorage: AnyObject {

	var service: IStoryService! { get set }
	var stories: [BaseStory] { get }
	func fetchStories(completion: @escaping StoriesBlock)

}
