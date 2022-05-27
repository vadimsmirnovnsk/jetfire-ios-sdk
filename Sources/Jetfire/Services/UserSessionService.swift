import JetfireProtobuf
import Foundation
import CoreTelephony
import UIKit

protocol IUserSessionService {
    func user() -> JetFireUser
    func session() -> JetFireSession
    func requestUser() -> JetFireRequestUser
    func requestSession() -> JetFireRequestSession
}

// MARK: - IUserProperty

private protocol IUserProperty {
    var key: String { get }
    var value: String? { get }
    var numericValue: Double? { get }
}

extension DBUserProperty: IUserProperty {}
extension DBSessionProperty: IUserProperty {}

// MARK: - UserSessionService

final class UserSessionService: IUserSessionService {

	private let userId: APIUserId
	private let sessionId: APISessionId

	private lazy var app: JetFireApp = {
		return JetFireApp.with {
			$0.version = Constants.appVersion
		}
	}()

    private lazy var sdk: JetFireSdk = {
        return JetFireSdk.with {
            $0.version = "1"
        }
    }()

	private lazy var device: JetFireDevice = {
		return JetFireDevice.with {
			$0.platform = Constants.mobileOSName
			$0.vendor = Constants.mobileVendorName
			$0.model = Constants.mobilePlatformModel
			$0.os = Constants.mobileOSName
			$0.osVersion = Constants.platformOSVersion
			$0.language = Constants.currentLanguage
            $0.locale = Constants.currentLocale
			$0.timeZone = Constants.currentTimeZone
			$0.carrier = self.carriers
			$0.screen = self.screen
		}
	}()

	private var carriers: [String] {
		return CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.compactMap { $0.value.carrierName } ?? []
	}

	private lazy var screen: JetFireScreen = {
		return JetFireScreen.with {
			$0.width = Int32(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height))
			$0.height = Int32(max(UIScreen.main.bounds.width, UIScreen.main.bounds.height))
			$0.dpi = Int32(UIScreen.main.scale)
		}
	}()

    private let databaseService: IDatabaseService

    init(userId: APIUserId, sessionId: APISessionId, databaseService: IDatabaseService) {
		self.userId = userId
		self.sessionId = sessionId
        self.databaseService = databaseService
	}

	func user() -> JetFireUser {
		return JetFireUser.with {
			$0.uuid = self.userId.rawValue
            $0.properties = self.databaseService
                .getUserProperties()
                .map(\.jetFireProperty)
		}
	}

	func session() -> JetFireSession {
		return JetFireSession.with {
			$0.uuid = self.sessionId.rawValue
			$0.timestamp = Date().timeIntervalSince1970.timestamp
			$0.app = self.app
			$0.device = self.device
            $0.sdk = self.sdk
            $0.properties = self.databaseService
                .getSessionProperties()
                .map(\.jetFireProperty)
		}
	}

	func requestUser() -> JetFireRequestUser {
		return JetFireRequestUser.with {
			$0.uuid = self.userId.rawValue
		}
	}

	func requestSession() -> JetFireRequestSession {
		return JetFireRequestSession.with {
			$0.uuid = self.sessionId.rawValue
		}
	}

}

// MARK: - IUserProperty

private extension IUserProperty {
    var jetFireProperty: JetFireProperty {
        JetFireProperty.with {
            $0.name = self.key
            $0.value = JetFireAnyValue.with {
                if let doubleValue = self.numericValue {
                    $0.double = doubleValue
                } else if let stringValue = self.value {
                    $0.string = stringValue
                }
            }
        }
    }
}
