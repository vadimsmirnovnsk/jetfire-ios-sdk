import Foundation

/// Создает задачи планировщика
final class SchedulerTaskFactory {

    private let triggeredCampaignsProvider: ITriggeredCampaignsProvider
    private let storiesDataSource: IMutableStoriesDataSource

    init(
        triggeredCampaignsProvider: ITriggeredCampaignsProvider,
        storiesDataSource: IMutableStoriesDataSource
    ) {
        self.triggeredCampaignsProvider = triggeredCampaignsProvider
        self.storiesDataSource = storiesDataSource
    }

    func makeStorableTask(
        story: JetFireFeatureStory,
        campaignId: Int64
    ) -> SchedulerStorableTask {
        SchedulerStorableTask(
            type: .story,
            campaignId: campaignId,
            storyId: story.id,
            activationDate: story.activationDate(),
            expirationDate: story.expirationDate()
        )
    }

    func makeLiveTask(
        storableTask: SchedulerStorableTask,
        completion: @escaping () -> Void
    ) -> SchedulerLiveTask? {
        switch storableTask.type {
        case .story:
            if let storyId = storableTask.storyId {
                return SchedulerLiveTask(
                    task: storableTask,
                    taskActivator: StoryTaskActivator(
                        storyId: storyId,
                        campaignId: storableTask.campaignId,
                        triggeredCampaignsProvider: self.triggeredCampaignsProvider,
                        storiesDataSource: self.storiesDataSource
                    ),
                    completion: completion
                )
            } else {
                assertionFailure("No storyId found")
                return nil
            }
        case .push:
            return nil
        }
    }
}

// MARK: - JetFireFeatureStory

private extension JetFireFeatureStory {

    func activationDate() -> Date? {
        if self.hasSchedule {
            if self.schedule.hasAtTime {
                return Date(timeIntervalSince1970: Double(self.schedule.atTime.value) / 1000)
            } else if self.schedule.hasAfter {
                return Date().appendingSeconds(Int(self.schedule.after))
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    func expirationDate() -> Date? {
        if self.hasExpire {
            if self.schedule.hasAtTime {
                return Date(timeIntervalSince1970: Double(self.schedule.atTime.value) / 1000)
            } else if self.schedule.hasAfter, let activationDate = self.activationDate() {
                return activationDate.appendingSeconds(Int(self.schedule.after))
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
