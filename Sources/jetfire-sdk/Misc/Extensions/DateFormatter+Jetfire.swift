import Foundation

extension DateFormatter {

	static let preferencesDateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.formatterBehavior = .behavior10_4
		df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
		return df
	}()

	static let yyyyMMdd: DateFormatter = {
		let df = DateFormatter()
		df.formatterBehavior = .behavior10_4
		df.dateFormat = "yyyyMMdd"
		return df
	}()

	static let db_yyyy_mm_dd: DateFormatter = {
		let df = DateFormatter()
		df.formatterBehavior = .behavior10_4
		df.dateFormat = "yyyy-MM-dd"
		return df
	}()

    static let dateTime: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy HH:mm:ss"
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
