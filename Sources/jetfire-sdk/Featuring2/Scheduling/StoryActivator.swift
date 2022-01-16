import Foundation

/// Активирует задание планировщика — добавляет историю в карусель
protocol ISchedulerTaskActivator {
    func activate()
}

// MARK: - StoryTaskActivator

final class StoryTaskActivator: ISchedulerTaskActivator {

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
        guard let story = story else { return }
        self.storiesDataSource.append(story: story, campaignId: self.campaignId)
    }
}
