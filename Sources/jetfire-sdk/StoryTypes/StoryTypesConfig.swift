import UIKit
import VNBase
import VNEssential
import VNHandlers

/// Класс, который конфигурирует доступные типы снапов и сториз.
public class StoryTypesConfig {

	public var snapButtonForegroundColor = UIColor.tinkoffAnimationYellow
	public var snapTitleTextStyle = TextStyle.storyTitleBlack()
	public var snapSubitleTextStyle = TextStyle.system17White
	public var snapButtonTextStyle = TextStyle.systemSemiBold19Black

	let storiesService: StoriesService

	init(
		api: IAPIService,
		ud: IUserDefaults,
		storage: IStoriesStorage,
		processTargetService: ProcessTargetService,
		router: BaseRouter
	) {
		self.storiesService = StoriesService(
			router: router,
			api: api,
			storage: storage,
			processTargetService: processTargetService,
			ud: ud
		)
	}

}
