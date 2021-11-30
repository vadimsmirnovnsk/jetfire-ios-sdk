import Foundation

extension DateFormatter {

	static let preferencesDateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.formatterBehavior = .behavior10_4
		df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
		return df
	}()
	static let YYYYMMDD: DateFormatter = {
		let df = DateFormatter()
		df.formatterBehavior = .behavior10_4
		df.dateFormat = "YYYYMMdd"
		return df
	}()
	static let db_yyyy_mm_dd: DateFormatter = {
		let df = DateFormatter()
		df.formatterBehavior = .behavior10_4
		df.dateFormat = "YYYY-MM-dd"
		return df
	}()

}

extension Date {

	static var now: Date {
		#if DEBUG
		return Date()
		#else
		return Date()
		#endif
	}

	static var today: Date = {
		return Date.now
	}()

	var dmyComponents: DateComponents {
		let cal = Calendar.current
		let dc = cal.dateComponents([.day, .month, .year], from: self)
		return dc
	}

}
