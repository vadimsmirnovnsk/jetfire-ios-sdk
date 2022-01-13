import Foundation

final class StoryScheduler {

	private let storiesService: IStoryService
	private let router: FeaturingRouter
	private let pushService: FeaturingPushService
	private let ud: IFUserDefaults

	init(router: FeaturingRouter, storiesService: IStoryService, pushService: FeaturingPushService, ud: IFUserDefaults) {
		self.router = router
		self.storiesService = storiesService
		self.pushService = pushService
		self.ud = ud
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
			self.router.showToaster(style: .button(
				title: campaign.campaign.toaster.title,
				button: campaign.campaign.toaster.actionButton.title,
				completion: { [weak self] in
					self?.storiesService.show(story: campaign.story, in: [campaign.story])
				}))
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
