import VNEssential
import UIKit
import UIColorHexSwift
import VNBase

/// Делает `ToasterView` из `JetFireFeatureToaster`
final class ToasterFactory {

    private let storiesService: IStoriesService
    private let storiesFactory: StoriesFactory
    private let jetfireAnalytics: JetfireAnalytics

    init(
        storiesService: IStoriesService,
        storiesFactory: StoriesFactory,
        jetfireAnalytics: JetfireAnalytics
    ) {
        self.storiesService = storiesService
        self.storiesFactory = storiesFactory
        self.jetfireAnalytics = jetfireAnalytics
    }

    func makeToaster(toaster: JetFireFeatureToaster, campaign: JetFireCampaign) -> ToasterView {
        #warning("Доработать ToasterView чтобы учесть все возможности JetFireFeatureToaster")
        let style: ToasterView.Style = .button(
            title: toaster.title,
            button: toaster.actionButton.title,
            completion: { [weak self] in
                guard let self = self else { return }
                self.jetfireAnalytics.trackToasterTap(campaignId: campaign.id)
                let stories = campaign.stories.map {
                    self.storiesFactory.makeStory(story: $0, campaignId: campaign.id)
                }
                guard let story = stories.first else { return }
                self.storiesService.show(story: story, in: stories)
            }
        )
        return ToasterView(style: style)
    }
}
