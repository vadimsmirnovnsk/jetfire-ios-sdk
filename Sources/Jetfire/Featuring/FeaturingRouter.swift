import VNBase

final class FeaturingRouter: BaseRouter {

	private unowned let container: Jetfire

	init(container: Jetfire) {
		self.container = container
	}

}
