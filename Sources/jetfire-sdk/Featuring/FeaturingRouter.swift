import VNBase

final class FeaturingRouter: BaseRouter {

	private unowned let container: Jetfire

	init(container: Jetfire) {
		self.container = container
	}

	func showToaster(style: ToasterView.Style, visualStyle: ToasterView.VisualStyle = .green) {
		self.container.toaster(style: style, visualStyle: visualStyle).show()
	}

}
