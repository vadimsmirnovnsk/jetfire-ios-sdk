import Foundation

enum JetfireError: Error, LocalizedError {

	case apiNilDataError
	case apiUnwrapDataError
	case apiProtoUnwrapZeroDataError
	case apiProtoWrapError
	case apiGeneral
	case api500Error(code: Int)

	case permissionFailed

	var errorDescription: String? {
		switch self {
			default: return "Jetfire general error"
		}
	}

	var failureReason: String? {
		switch self {
			default: return "Jetfire general error description"
		}
	}

}
