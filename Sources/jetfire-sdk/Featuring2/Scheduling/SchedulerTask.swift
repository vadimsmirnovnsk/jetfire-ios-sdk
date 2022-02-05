import Foundation

/// Активная задача планировщика
/// Если наступило время активации, то активирует себя посредством активатора :)
final class SchedulerTask {

    private let task: SchedulerStorableTask
    private let taskActivator: ISchedulerTaskActivator

    init(
        task: SchedulerStorableTask,
        taskActivator: ISchedulerTaskActivator
    ) {
        self.task = task
        self.taskActivator = taskActivator
    }

    func tick() {
        if self.task.isExpired {
            self.taskActivator.deactivate()
        } else if self.task.canBeActivated {
            self.taskActivator.activate()
        }
    }
}
