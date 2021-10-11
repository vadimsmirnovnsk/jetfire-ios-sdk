import UIKit
import VNEssential

public class FirebaseConfig {

	/// [ Firebase Stories
	var firebaseStorySnapButtonForegroundColor = UIColor.tinkoffAnimationYellow
	var firebaseStoryTitleTextStyle = TextStyle.storyTitleBlack()
	var firebaseStorySubitleTextStyle = TextStyle.system17White
	var firebaseStoryButtonTextStyle = TextStyle.systemSemiBold19Black

	var openURLHandler: IOpenURLHandler? = nil {
		didSet {
			self.processTargetService.deeplinkService = self.openURLHandler
		}
	}
	internal let storiesService: StoriesService
	private let ud: IUserDefaults
	private let storage: StoriesStorage
	private let processTargetService: ProcessTargetService
	private let router: IRouter = StoryRouter()
	private let api: IAPIService
	/// ] Firebase Stories

	init(api: IAPIService, ud: IUserDefaults) {
		self.ud = ud
		self.api = api
		self.processTargetService = ProcessTargetService(application: UIApplication.shared)
		self.storage = StoriesStorage(processTargetService: self.processTargetService, router: self.router)
		self.storiesService = StoriesService(
			router: self.router,
			api: api,
			storage: self.storage,
			processTargetService: self.processTargetService,
			ud: ud
		)
	}

}
