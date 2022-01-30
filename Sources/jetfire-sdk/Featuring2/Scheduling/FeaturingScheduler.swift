import Foundation

/// Планировщик сторис, тостеров, пушей
protocol IFeaturingScheduler {
    func start()
}

// MARK: - FeaturingScheduler

final class FeaturingScheduler: IFeaturingScheduler {

    private let triggeredCampaignsProvider: ITriggeredCampaignsProvider
    private let factory: SchedulerTaskFactory
    private let userSettings: IUserSettings
    private var started: Bool = false
    private var timer: Timer?

    private var storableTasks: [SchedulerStorableTask] {
        get { self.userSettings.schedulerStorableTasks }
        set { self.userSettings.schedulerStorableTasks = newValue }
    }

    private var tasks: [SchedulerStorableTask: SchedulerTask] = [:]

    init(
        triggeredCampaignsProvider: ITriggeredCampaignsProvider,
        factory: SchedulerTaskFactory,
        userSettings: IUserSettings
    ) {
        self.triggeredCampaignsProvider = triggeredCampaignsProvider
        self.factory = factory
        self.userSettings = userSettings
    }

    func start() {
        guard !self.started else { return }
        self.started = true
        self.tasks = self.makeTasks()
        self.timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(self.timerTick),
            userInfo: nil,
            repeats: true
        )
        self.triggeredCampaignsProvider.onUpdate.add(self) { [weak self] isChanged in
            self?.refresh()
        }
    }
}

// MARK: - Private

extension FeaturingScheduler {

    private func refresh() {
        self.scheduleTasks()
        self.timerTick()
    }

    private func scheduleTasks() {
        var triggeredTasks: [SchedulerStorableTask] = []
        for campaign in self.triggeredCampaignsProvider.campaigns {
            let stories = campaign.stories.map {
                self.factory.makeStorableTask(story: $0, campaignId: campaign.id)
            }
            let toasters = campaign.hasToaster ? [campaign.toaster].map {
                self.factory.makeStorableTask(toaster: $0, campaignId: campaign.id)
            } : []
            triggeredTasks.append(toasters)
            triggeredTasks.append(stories)
        }
        let newStorableTasks = sync(oldTasks: self.storableTasks, newTasks: triggeredTasks)
        if self.storableTasks != newStorableTasks {
            self.storableTasks = newStorableTasks
            self.tasks = self.makeTasks()
        }
    }

    private func makeTasks() -> [SchedulerStorableTask: SchedulerTask] {
        Dictionary(uniqueKeysWithValues: self.storableTasks.compactMap { storable in
            self.factory.makeTask(storableTask: storable) { [weak self] in
                self?.remove(storableTask: storable)
            }
            .map { ($0.task, $0) }
        })
    }

    private func remove(storableTask: SchedulerStorableTask) {
        if let index = self.storableTasks.firstIndex(of: storableTask) {
            self.storableTasks.remove(at: index)
        }
        self.tasks[storableTask] = nil
    }

    @objc private func timerTick() {
        self.tasks.values.forEach { $0.tick() }
    }
}

// MARK: - Private

private func sync(oldTasks: [SchedulerStorableTask], newTasks: [SchedulerStorableTask]) -> [SchedulerStorableTask] {
    var result: [SchedulerStorableTask] = []
    for newItem in newTasks {
        if let index = oldTasks.firstIndex(of: newItem) {
            let existingItem = oldTasks[index]
            result.append(existingItem)
        } else {
            result.append(newItem)
        }
    }
    return result
}
