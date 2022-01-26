import Foundation

/// Активирует задание планировщика —
/// добавляет историю в карусель, показывает тостер и т.п.
protocol ISchedulerTaskActivator {
    func activate()
}
