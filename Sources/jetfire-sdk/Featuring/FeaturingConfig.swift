import UIKit
import VNEssential

internal class FeaturingConfig {

	/// [ Featuring
	let featuring: FeaturingService
	private let featuringManager: FeaturingManager
	private let featuringStorage: FeaturingStorage
	private let featuringPushService: FeaturingPushService
	/// ] Featuring

	private let api: IAPIService&IFeaturingAPI
	private let ud: IFUserDefaults
	private let storiesService: StoriesService
	private let userUUID: String

	init(
		api: IAPIService&IFeaturingAPI,
		ud: IFUserDefaults,
		storiesService: StoriesService,
		userUUID: String,
		dbAnalytics: DBAnalytics
	) {
		self.api = api
		self.ud = ud
		self.storiesService = storiesService
		self.userUUID = userUUID

		self.featuringStorage = FeaturingStorage(
			storiesService: storiesService,
			api: api,
			userId: userUUID
		)
		self.featuringManager = FeaturingManager(ud: ud, storage: self.featuringStorage)
		self.featuringPushService = FeaturingPushService(ud: self.ud)
		self.featuring = FeaturingService(
			manager: self.featuringManager,
			storiesService: self.storiesService,
			pushService: self.featuringPushService,
			dbAnalytics: dbAnalytics,
			ud: ud
		)
	}

}
