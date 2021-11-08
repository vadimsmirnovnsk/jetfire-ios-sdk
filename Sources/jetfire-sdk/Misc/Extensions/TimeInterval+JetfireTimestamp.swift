import Foundation

extension TimeInterval {

	var timestamp: JetFireTimestamp {
		JetFireTimestamp.with {
			$0.value = Int64(self * 1000)
		}
	}

}
