import Foundation

/// Создает задачи планировщика
final class SchedulerTaskFactory {

    private let triggeredCampaignsProvider: ITriggeredCampaignsProvider
    private let storiesDataSource: IMutableStoriesDataSource
    private let toasterFactory: ToasterFactory
    private let jetfireAnalytics: JetfireAnalytics
    private let ud: IUserSettings
    private let rulesProvider: IFeaturingRulesProvider

    init(
        triggeredCampaignsProvider: ITriggeredCampaignsProvider,
        storiesDataSource: IMutableStoriesDataSource,
        toasterFactory: ToasterFactory,
        jetfireAnalytics: JetfireAnalytics,
        ud: IUserSettings,
        rulesProvider: IFeaturingRulesProvider
    ) {
        self.triggeredCampaignsProvider = triggeredCampaignsProvider
        self.storiesDataSource = storiesDataSource
        self.toasterFactory = toasterFactory
        self.jetfireAnalytics = jetfireAnalytics
        self.ud = ud
        self.rulesProvider = rulesProvider
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

    func makeStorableTask(
        toaster: JetFireFeatureToaster,
        campaignId: Int64
    ) -> SchedulerStorableTask {
        SchedulerStorableTask(
            type: .toaster,
            campaignId: campaignId,
            storyId: nil,
            activationDate: toaster.activationDate(),
            expirationDate: toaster.expirationDate()
        )
    }

    func makeTask(storableTask: SchedulerStorableTask) -> SchedulerTask? {
        switch storableTask.type {
        case .story:
            if let storyId = storableTask.storyId {
                return SchedulerTask(
                    task: storableTask,
                    taskActivator: StoryActivator(
                        storyId: storyId,
                        campaignId: storableTask.campaignId,
                        storiesDataSource: self.storiesDataSource
                    )
                )
            } else {
                assertionFailure("No storyId found")
                return nil
            }
        case .toaster:
            return SchedulerTask(
                task: storableTask,
                taskActivator: ToasterActivator(
                    campaignId: storableTask.campaignId,
                    triggeredCampaignsProvider: self.triggeredCampaignsProvider,
                    factory: self.toasterFactory,
                    jetfireAnalytics: self.jetfireAnalytics,
                    ud: self.ud,
                    rulesProvider: self.rulesProvider
                )
            )
        }
    }
}

// MARK: - IScheduleSupport

protocol IScheduleSupport {
    var hasSchedule: Bool { get }
    var schedule: JetFireSchedule { get }
    var hasExpire: Bool { get }
    var expire: JetFireSchedule { get }
}

extension JetFireFeatureStory: IScheduleSupport {}
extension JetFireFeatureToaster: IScheduleSupport {}

private extension IScheduleSupport {

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
            if self.expire.hasAtTime {
                return Date(timeIntervalSince1970: Double(self.expire.atTime.value) / 1000)
            } else if self.expire.hasAfter, let activationDate = self.activationDate() {
                return activationDate.appendingSeconds(Int(self.expire.after))
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
