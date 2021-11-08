import UIKit

// Класс достаёт настройки из плиста

struct InfoPlist: Codable {

	var deeplinkScheme: String
	var apiKey: String

	enum CodingKeys: String, CodingKey {
		case deeplinkScheme = "DEEPLINK_SCHEME"
		case apiKey = "API_KEY"
	}

}

class ServiceInfo {

	static let kUnknownKeyString = "Unknown"
	private static let serviceFilename = "JetfireService-Info"

	var deeplinkScheme: String {
		guard let scheme = self.plist?.deeplinkScheme else {
			print("❌ Jetfire didn't load deeplink scheme in \(Self.serviceFilename).plist")
			return ServiceInfo.kUnknownKeyString
		}
		return scheme
	}

	var apiKey: String {
		guard let apiKey = self.plist?.apiKey else {
			print("❌ Jetfire didn't load API Key in \(Self.serviceFilename).plist")
			return ServiceInfo.kUnknownKeyString
		}
		return apiKey
	}

	private var plist: InfoPlist?

	init() {
		self.plist = self.plist(withName: Self.serviceFilename)
		print("Jetfire loaded deeplink scheme: \(self.deeplinkScheme)")
	}

	private func plist(withName name: String) -> InfoPlist? {
		guard  let path = Bundle.main.path(forResource: name, ofType: "plist"),
			let xml = FileManager.default.contents(atPath: path),
			let preferences = try? PropertyListDecoder().decode(InfoPlist.self, from: xml) else
		{
			print("❌ Jetfire didn't load \(Self.serviceFilename).plist")
			return nil
		}

		print("✅ Jetfire loaded JetfireService-Info.plist")
		print(preferences)
		return preferences
	}

}
