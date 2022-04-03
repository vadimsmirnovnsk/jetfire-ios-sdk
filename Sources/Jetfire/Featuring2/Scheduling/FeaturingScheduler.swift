import Foundation

/// Планировщик сторис, тостеров, пушей
protocol IFeaturingScheduler {
    func start()
}

// MARK: - FeaturingScheduler

final class FeaturingScheduler: IFeaturingScheduler {

    private let storiesCampaignsProvider: IStoriesCampaignsProvider
    private let triggeredCampaignsProvider: ITriggeredCampaignsProvider
    private let factory: SchedulerTaskFactory
    private let userSettings: IUserSettings
    private var started: Bool = false
    private var timer: Timer?

    private lazy var storableTasks = { self.makeStorableTasks() }() {
        didSet {
            self.userSettings.schedulerStorableTasks = self.storableTasks.elements
        }
    }

    private var tasks: [SchedulerTask] = []

    init(
        storiesCampaignsProvider: IStoriesCampaignsProvider,
        triggeredCampaignsProvider: ITriggeredCampaignsProvider,
        factory: SchedulerTaskFactory,
        userSettings: IUserSettings
    ) {
        self.storiesCampaignsProvider = storiesCampaignsProvider
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
        self.refresh()
        self.storiesCampaignsProvider.onUpdate.add(self) { [weak self] in
            self?.refresh()
        }
        self.triggeredCampaignsProvider.onUpdate.add(self) { [weak self] in
            self?.refresh()
        }
        self.storiesCampaignsProvider.refresh()
        self.triggeredCampaignsProvider.refresh()
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
        for campaign in self.storiesCampaignsProvider.campaigns {
            let stories = campaign.stories.map {
                self.factory.makeStorableTask(story: $0, campaignId: campaign.id)
            }
            triggeredTasks.append(stories)
        }
        for campaign in self.triggeredCampaignsProvider.campaigns {
            let toasters = campaign.hasToaster ? [campaign.toaster].map {
                self.factory.makeStorableTask(toaster: $0, campaignId: campaign.id)
            } : []
            triggeredTasks.append(toasters)
        }
        self.sync(newTasks: triggeredTasks)
    }

    private func sync(newTasks: [SchedulerStorableTask]) {
        var result: OrderedSet<SchedulerStorableTask> = []
        for newItem in newTasks {
            if let index = self.storableTasks.firstIndex(of: newItem) {
                let existingItem = self.storableTasks[index]
                result.append(existingItem)
            } else {
                result.append(newItem)
            }
        }
        if self.storableTasks != result {
            self.storableTasks = result
            self.tasks = self.makeTasks()
            Log.info("Sheduler tasks: \(self.tasks.debugDescription)")
        }
    }

    private func makeTasks() -> [SchedulerTask] {
        self.storableTasks.compactMap { self.factory.makeTask(storableTask: $0) }
    }

    private func makeStorableTasks() -> OrderedSet<SchedulerStorableTask> {
        OrderedSet(self.userSettings.schedulerStorableTasks)
    }

    @objc private func timerTick() {
        self.tasks.forEach { $0.tick() }
    }
}
