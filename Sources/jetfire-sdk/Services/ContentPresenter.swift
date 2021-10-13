class ContentPresenter: ICanShowContent {

	func showStory(with id: String) {
		print("Should load and show story with id: \(id)")
	}

	func showTrigger(with id: String) {
		print("Should load and show trigger with id: \(id)")
	}

}
