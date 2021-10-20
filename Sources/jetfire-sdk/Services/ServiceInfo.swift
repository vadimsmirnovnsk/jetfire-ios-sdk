import UIKit

// Класс достаёт настройки из плиста

struct InfoPlist: Codable {

	var deeplinkScheme: String

	enum CodingKeys: String, CodingKey {
		case deeplinkScheme = "DEEPLINK_SCHEME"
	}

}

class ServiceInfo {

	var deeplinkScheme: String {
		guard let scheme = self.plist?.deeplinkScheme else {
			print("❌ Jetfire didn't load deeplink scheme in JetfireService-Info.plist")
			return "unknown"
		}
		return scheme
	}

	private var plist: InfoPlist?

	init() {
		self.plist = self.plist(withName: "JetfireServices-Info")
		print("Jetfire loaded deeplink scheme: \(self.deeplinkScheme)")
	}

	private func plist(withName name: String) -> InfoPlist? {
		guard  let path = Bundle.main.path(forResource: name + ".plist", ofType: ""),
			let xml = FileManager.default.contents(atPath: path),
			let preferences = try? PropertyListDecoder().decode(InfoPlist.self, from: xml) else
		{
			print("❌ Jetfire didn't load JetfireService-Info.plist")
			return nil
		}

		"✅ Jetfire didn't load JetfireService-Info.plist"
		print(preferences)
		return preferences
	}

}
