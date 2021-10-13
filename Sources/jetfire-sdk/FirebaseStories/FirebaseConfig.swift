import UIKit
import VNBase
import VNEssential
import VNHandlers

public class FirebaseConfig {

	public var firebaseStorySnapButtonForegroundColor = UIColor.tinkoffAnimationYellow
	public var firebaseStoryTitleTextStyle = TextStyle.storyTitleBlack()
	public var firebaseStorySubitleTextStyle = TextStyle.system17White
	public var firebaseStoryButtonTextStyle = TextStyle.systemSemiBold19Black

	let storiesService: StoriesService

	private let ud: IUserDefaults
	private let storage: StoriesStorage
	private let processTargetService: ProcessTargetService
	private let router: BaseRouter
	private let api: IAPIService

	init(api: IAPIService, ud: IUserDefaults, deeplinkService: IOpenURLHandler, application: UIApplication, router: BaseRouter) {
		self.ud = ud
		self.api = api
		self.router = router
		self.processTargetService = ProcessTargetService(application: application, deeplinkService: deeplinkService)
		self.storage = StoriesStorage(processTargetService: self.processTargetService, router: self.router)
		self.storiesService = StoriesService(
			router: router,
			api: api,
			storage: self.storage,
			processTargetService: self.processTargetService,
			ud: ud
		)
	}

}
