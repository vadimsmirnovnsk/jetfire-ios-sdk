import VNEssential
//typealias StoriesBlock = ([BaseStory]) -> Void

protocol IStoriesStorage: AnyObject {

	/// Событие обновления данных. true — успешно, false — неуспешно
	var onUpdateData: Event<Bool> { get }

	var service: IStoryService! { get set }
	var stories: [BaseStory] { get }

	/// Перезагрузить данные сториз с сервера
	func refetchStories(completion: @escaping BoolBlock)

}
