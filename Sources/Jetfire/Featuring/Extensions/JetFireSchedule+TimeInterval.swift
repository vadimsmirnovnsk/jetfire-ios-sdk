import Foundation

extension JetFireSchedule {

	var afterInterval: TimeInterval? {
		if self.hasAfter {
			return self.after.timeInterval
		} else if self.hasAtTime {
			let now = Date().timeIntervalSince1970
			let atTime = self.atTime.value.timeInterval

			guard atTime > now else { return nil }
			return atTime - now
		}

		return 0.001
	}

}
