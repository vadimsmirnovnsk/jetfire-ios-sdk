import Foundation

extension Int64 {

	var string: String { String(self) }
	var eventType: JetFireEventType { JetFireEventType.with { $0.value = self } }
	var msToSecondsTimeInterval: TimeInterval { TimeInterval(self) / 1000 } /// milliseconds → seconds
	var timeInterval: TimeInterval { TimeInterval(self) }

}
