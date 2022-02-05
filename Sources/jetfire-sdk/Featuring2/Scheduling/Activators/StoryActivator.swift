import Foundation

/// Активирует задание планировщика — добавляет историю в карусель
final class StoryActivator: ISchedulerTaskActivator {

    private let storyId: Int64
    private let campaignId: Int64
    private let storiesDataSource: IMutableStoriesDataSource

    init(
        storyId: Int64,
        campaignId: Int64,
        storiesDataSource: IMutableStoriesDataSource
    ) {
        self.storyId = storyId
        self.campaignId = campaignId
        self.storiesDataSource = storiesDataSource
    }

    func activate() {
        self.storiesDataSource.append(storyId: self.storyId, campaignId: self.campaignId)
    }

    func deactivate() {
        self.storiesDataSource.remove(storyId: self.storyId, campaignId: self.campaignId)
    }
}
