import UIKit

// Класс достаёт настройки из плиста

struct InfoPlist: Codable {

	var deeplinkScheme: String

}

class ServiceInfo {

	var deeplinkScheme: String { "jetfiredemomock" }

	private var plist: InfoPlist?

	init() {
		self.plist = self.plist(withName: "JetfireServices-Info")
	}

	private func plist(withName name: String) -> InfoPlist? {
		guard  let path = Bundle.main.path(forResource: name, ofType: "plist"),
			let xml = FileManager.default.contents(atPath: path),
			let preferences = try? PropertyListDecoder().decode(InfoPlist.self, from: xml) else
		{
			print("❌ Jetfire didn't load JetfireService-Info.plist")
			return nil
		}

		print(preferences)
		return preferences
	}

}
