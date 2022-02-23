import Foundation

extension DateFormatter {

	/// 2018-05-15T16:27:20.6101843
	static var featuringDateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.formatterBehavior = .behavior10_4
		df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
		return df
	}()

}
