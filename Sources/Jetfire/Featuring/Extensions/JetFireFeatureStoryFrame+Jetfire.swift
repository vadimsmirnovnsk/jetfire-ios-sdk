extension JetFireFeatureStoryFrame {

	func storyButton() -> StoryButton? {
		guard self.hasActionButton else { return nil }

		let button = StoryButton(
			id: self.id.string,
			title: self.actionButton.title,
			urlString: nil,
			deeplinkString: self.actionButton.action.deeplink,
			closeStory: true
		)

		return button
	}

}
