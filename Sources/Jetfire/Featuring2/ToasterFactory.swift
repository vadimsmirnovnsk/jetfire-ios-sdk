import VNEssential
import UIKit
import UIColorHexSwift
import VNBase

/// Делает `ToasterView` из `JetFireFeatureToaster`
final class ToasterFactory {

    private let storiesService: IStoriesService
    private let storiesFactory: StoriesFactory
    private let jetfireAnalytics: IStoriesAnalytics

    init(
        storiesService: IStoriesService,
        storiesFactory: StoriesFactory,
        jetfireAnalytics: IStoriesAnalytics
    ) {
        self.storiesService = storiesService
        self.storiesFactory = storiesFactory
        self.jetfireAnalytics = jetfireAnalytics
    }

    func makeToaster(toaster: JetFireFeatureToaster, campaign: JetFireCampaign) -> ToasterView {
		let completion: VoidBlock = { [weak self] in
			guard let self = self else { return }
			self.jetfireAnalytics.trackToastDidTap(campaignId: campaign.id)
			let stories = campaign.stories.map {
				self.storiesFactory.makeStory(story: $0, campaignId: campaign.id)
			}
			guard let story = stories.first else { return }
			self.storiesService.show(story: story, in: stories)
		}

		let behavior: ToasterView.Behavior
		if toaster.hasActionButton {
			behavior = .concrete(
				message: toaster.message,
				imageURL: URL(string: toaster.image.url),
				button: toaster.actionButton.title,
				closeButton: toaster.hideButton.title,
				completion: completion
			)
		} else {
			behavior = .dismissable(
				message: toaster.message,
				imageURL: URL(string: toaster.image.url),
				completion: completion
			)
		}

		return ToasterView(
			config: Jetfire.standard.toast,
			behavior: behavior,
			visualStyle: Jetfire.standard.toastVisualStyle,
			analytics: self.jetfireAnalytics,
			campaignId: campaign.id
		)
    }
}
