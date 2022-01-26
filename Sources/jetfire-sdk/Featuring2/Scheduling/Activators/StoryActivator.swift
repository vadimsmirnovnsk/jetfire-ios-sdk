import Foundation

/// Активирует задание планировщика — добавляет историю в карусель
final class StoryActivator: ISchedulerTaskActivator {

    private let storyId: Int64
    private let campaignId: Int64
    private let triggeredCampaignsProvider: ITriggeredCampaignsProvider
    private let storiesDataSource: IMutableStoriesDataSource

    init(
        storyId: Int64,
        campaignId: Int64,
        triggeredCampaignsProvider: ITriggeredCampaignsProvider,
        storiesDataSource: IMutableStoriesDataSource
    ) {
        self.storyId = storyId
        self.campaignId = campaignId
        self.triggeredCampaignsProvider = triggeredCampaignsProvider
        self.storiesDataSource = storiesDataSource
    }

    func activate() {
        let campaigns = self.triggeredCampaignsProvider.campaigns
        let campaign = campaigns.first { $0.id == self.campaignId }
        let story = campaign?.stories.first { $0.id == self.storyId }
        // Если на момент активации историю не нашли в тригере,
        // значит состояние приложения поменялось, и эта история
        // уже не актуальна, игнорируем ее
        guard let campaign = campaign, let story = story else { return }
        Log.info("Activate story \(campaign.debugDescription)")
        self.storiesDataSource.append(story: story, campaignId: self.campaignId)
    }
}
