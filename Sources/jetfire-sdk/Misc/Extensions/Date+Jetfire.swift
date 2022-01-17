import Foundation

extension Date {

	var morning: Date {
		var components = Calendar.current.dateComponents([ .year, .month, .day, .hour, .minute, .second ], from: self)
		components.calendar = Calendar.current
		components.hour = 0
		components.minute = 0
		components.second = 1
		return components.date!
	}

	/// + 24 часа
	var nextDay: Date {
		self.appendingDays(1)
	}

	func appendingDays(_ count: Int) -> Date {
		Calendar.current.date(byAdding: .day, value: count, to: self)!
	}

	func todayKey() -> Int {
		Int(self.morning.timeIntervalSince1970)
	}

    func appendingSeconds(_ value: Int) -> Date? {
        Calendar.current.date(byAdding: .second, value: value, to: self)
    }

}
