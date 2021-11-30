import Foundation

extension TimeInterval {

	var milliseconds: Int64 { Int64(self * 1000) }

	var timestamp: JetFireTimestamp {
		JetFireTimestamp.with {
			$0.value = self.milliseconds
		}
	}
}

extension Int64 {

	var int: Int { Int(self) }

}
