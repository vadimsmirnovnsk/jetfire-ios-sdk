import VNBase
import VNEssential
import UIKit

public protocol IRouter: AnyObject {

	func dismiss(animated: Bool, _ completion: VoidBlock?)
	func show(story: BaseStory, in stories: [BaseStory])

}

class StoryRouter: BaseRouter, IRouter {

	func show(story: BaseStory, in stories: [BaseStory]) {
		let vc = self.storiesVC(story: story, in: stories)
		vc.modalPresentationStyle = .fullScreen
		self.present(vc)
	}

	private func storiesVC(story: BaseStory, in stories: [BaseStory]) -> UIViewController {
		let vm = StoryBrowserVM(storiesService: Jetfire.standard.firebaseConfig.storiesService, stories: stories, since: story)
		let vc = StoryBrowserVC(viewModel: vm)
		return vc
	}

}
