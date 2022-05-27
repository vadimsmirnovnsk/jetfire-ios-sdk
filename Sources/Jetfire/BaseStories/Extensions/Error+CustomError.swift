import UIKit
import JetfireVNEssential

extension Error { // + Custom

	var isNoInternet: Bool {
		return [
			NSURLErrorNetworkConnectionLost,
			NSURLErrorNotConnectedToInternet
		].contains((self as NSError).code)
	}

	var analDescription: String {
		let error = (self as NSError)
		return self.isNoInternet ? "no_internet" : "\(error.domain):\(error.code)"
	}

	var bubbleDescription: String {
		return self.isNoInternet ? L10N("no internet.error") : L10N("error.general")
	}

	var analyticsCode: Int { return (self as NSError).code }

}
