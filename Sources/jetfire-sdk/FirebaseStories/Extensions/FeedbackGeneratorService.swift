import UIKit

internal class FeedbackGeneratorService {

	private static var impactDelay = false

	static func tick() {
		if !self.impactDelay {
//			AudioServicesPlaySystemSoundWithCompletion(1104, nil)
			let generator = UIImpactFeedbackGenerator(style: .light)
			generator.impactOccurred()
			self.impactDelay = true
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				self.impactDelay = false
			}
		}
	}

}
