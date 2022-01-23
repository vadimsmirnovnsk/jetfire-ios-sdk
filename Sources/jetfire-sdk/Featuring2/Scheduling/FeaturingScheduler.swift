import Foundation

/// Планировщик сторис, тостеров, пушей
protocol IFeaturingScheduler {
    func start()
}

// MARK: - FeaturingScheduler

final class FeaturingScheduler: IFeaturingScheduler {

    private let triggeredCampaignsProvider: ITriggeredCampaignsProvider
    private let factory: SchedulerTaskFactory
    private var started: Bool = false
    private var timer: Timer?

    #warning("Нужна сериализация")
    private var storableTasks: [SchedulerStorableTask] = []
    private var liveTasks: [SchedulerStorableTask: SchedulerLiveTask] = [:]

    init(
        triggeredCampaignsProvider: ITriggeredCampaignsProvider,
        factory: SchedulerTaskFactory
    ) {
        self.triggeredCampaignsProvider = triggeredCampaignsProvider
        self.factory = factory
    }

    func start() {
        guard !self.started else { return }
        self.started = true
        self.timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(self.timerTick),
            userInfo: nil,
            repeats: true
        )
        self.triggeredCampaignsProvider.onUpdate.add(self) { [weak self] isChanged in
            if isChanged {
                self?.refresh()
            }
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
        self.storableTasks = sync(oldTasks: self.storableTasks, newTasks: triggeredTasks)
        self.liveTasks = Dictionary(uniqueKeysWithValues: self.storableTasks.compactMap { storable in
            self.factory.makeLiveTask(storableTask: storable) { [weak self] in
                self?.remove(storableTask: storable)
            }
            .map { ($0.task, $0) }
        })
    }

    private func remove(storableTask: SchedulerStorableTask) {
        if let index = self.storableTasks.firstIndex(of: storableTask) {
            self.storableTasks.remove(at: index)
        }
        self.liveTasks[storableTask] = nil
    }

    @objc private func timerTick() {
        self.liveTasks.values.forEach { $0.tick() }
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
