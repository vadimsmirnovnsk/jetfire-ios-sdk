import JetfireVNBase
import UIKit

open class BaseSnap {

	public let snapVM: BaseSnapVM

	public required init(snapVM: BaseSnapVM) {
		self.snapVM = snapVM
	}

	func makeShit() -> UIView&IHaveViewModel {
		let view = self.snapVM.storyClass.init()
		view.viewModelObject = self.snapVM
		return view
	}

}
