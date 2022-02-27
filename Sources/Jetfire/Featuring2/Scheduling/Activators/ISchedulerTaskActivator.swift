import Foundation

/// Активирует или деактивирует задание планировщика —
/// добавляет историю в карусель, удаляет историю из карусели, показывает тостер и т.п.
protocol ISchedulerTaskActivator {
    func activate()
    func deactivate()
}
