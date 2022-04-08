import Foundation

/// Режим работы сервиса
public enum JetfireMode {
	case staging
	case production

	var plistFilename: String {
		switch self {
		case .production:
			return "JetfireService-Info-Production"
		case .staging:
			return "JetfireService-Info-Staging"
		}
	}
}
