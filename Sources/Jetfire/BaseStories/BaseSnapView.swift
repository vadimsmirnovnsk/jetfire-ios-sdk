import UIKit

// Базовый кадр истории
// Все истории будут наследоваться от неё
// Смысл — из вьюмодельки объект BaseSnap создаёт любые вьюхи и добавляет в сториз

protocol IWantBringSubviewsToFront: AnyObject {
	var bringSubviewsToFront: [UIView] { get }
}

open class BaseSnapView<TViewModel: BaseSnapVM>: BaseView<TViewModel>, IWantBringSubviewsToFront {
	/// Вьюхи (в основном кнопки), которые при переключении на снеп должны оказаться
	/// выше кнопок навигации по сториз
	var bringSubviewsToFront: [UIView] = []

}


open class BaseSnapVM: BaseCellVM {

	var isRead: Bool = false
	var storyClass: (UIView&IHaveViewModel&IWantBringSubviewsToFront).Type { BaseSnapView.self }
	var onPause: VoidBlock? = nil

	func pause() {
		self.onPause?()
	}

	func downloadContentIfNeeded() {

	}
}
