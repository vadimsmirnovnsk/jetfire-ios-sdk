import SwiftProtobuf
import Foundation
import CoreTelephony
import UIKit

final class UserSessionService {

	private let userId: APIUserId
	private let sessionId: APISessionId

	private lazy var app: JetFireApp = {
		return JetFireApp.with {
			$0.version = Constants.appVersion
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

	init(userId: APIUserId, sessionId: APISessionId) {
		self.userId = userId
		self.sessionId = sessionId
	}

	func user() -> JetFireUser {
		return JetFireUser.with {
			$0.uuid = self.userId.rawValue
			$0.properties = []
		}
	}

	func session() -> JetFireSession {
		return JetFireSession.with {
			$0.uuid = self.sessionId.rawValue
			$0.timestamp = JetFireTimestamp.with { $0.value = Int64(Date().timeIntervalSince1970) }
			$0.app = self.app
			$0.device = self.device
			$0.properties = []
		}
	}

}
