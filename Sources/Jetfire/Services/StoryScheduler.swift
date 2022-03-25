import Foundation

final class StoryScheduler {

	private let storiesService: IStoriesService
	private let router: FeaturingRouter
	private let pushService: FeaturingPushService
	private let ud: IUserSettings
	private let toasterFactory: ToasterFactory
	private let jetfireAnalytics: IStoriesAnalytics

	init(
		router: FeaturingRouter,
		storiesService: IStoriesService,
		pushService: FeaturingPushService,
		ud: IUserSettings,
		toasterFactory: ToasterFactory,
		jetfireAnalytics: IStoriesAnalytics
	) {
		self.router = router
		self.storiesService = storiesService
		self.pushService = pushService
		self.ud = ud
		self.toasterFactory = toasterFactory
		self.jetfireAnalytics = jetfireAnalytics
	}

	func scheduleShow(campaign: FeaturingCampaignAndStory, featuringType: FeaturingType) {
		let after: TimeInterval?
		switch featuringType {
			case .applicationStart:
				after = campaign.campaign.stories.first?.schedule.afterInterval
			case .deeplink, .push, .toaster:
				after = 0
		}

		if let after = after {
			DispatchQueue.main.asyncAfter(deadline: .now() + after) {
				self.storiesService.show(story: campaign.story, in: [campaign.story])
				self.rememberShow(campaign: campaign.campaign, featuringType: .applicationStart)
			}
		}
	}

	func scheduleToaster(campaign: FeaturingCampaignAndStory) {
		guard let after = campaign.campaign.toaster.schedule.afterInterval else { return }

		DispatchQueue.main.asyncAfter(deadline: .now() + after) {
			let toast = self.toasterFactory.makeToaster(toaster: campaign.campaign.toaster, campaign: campaign.campaign)
			self.jetfireAnalytics.trackToastDidShow(campaignId: campaign.campaign.id)
			toast.show()
			self.rememberShow(campaign: campaign.campaign, featuringType: .toaster)
		}
	}

	func schedulePush(campaign: FeaturingCampaignAndStory) {
		guard self.pushService.isGranted else {
			self.pushService.removeAllFeaturings()
			return
		}

		guard let after = campaign.campaign.push.schedule.afterInterval else { return }
		self.pushService.prepareFeaturing(campaign: campaign.campaign, after: after)
		self.pushService.schedulePreparedPush()
	}

	/// Запоминает, когда произошёл показ, чтобы не показывать фичеринги слишком часто
	func rememberShow(campaign: JetFireCampaign, featuringType: FeaturingType) {
		self.ud.showCampaign[campaign.id.string] = Date()
		self.remember(featuringType: featuringType)
	}

	private func remember(featuringType: FeaturingType) {
		switch featuringType {
			case .applicationStart: self.ud.lastApplicationStartShowDate = Date()
			case .push: self.ud.lastPushShowDate = Date()
			case .toaster:  self.ud.lastToasterShowDate = Date()
			case .deeplink: break
		}
	}

}
