import UIKit

protocol IPlistSettingsService {
    var current: PlistSettings { get }
}

// MARK: - PlistSettingsService

class PlistSettingsService: IPlistSettingsService {
    lazy var current: PlistSettings = {
		readAppSettings(mode: self.mode)
    }()

	private let mode: JetfireMode

	init(mode: JetfireMode) {
		self.mode = mode
	}
}

// MARK: - Private

extension PlistSettingsService {

	private func readAppSettings(mode: JetfireMode) -> PlistSettings {
        do {
            let decoder = PropertyListDecoder()
			let data = readDataFromMainBundle(name: mode.plistFilename)
            let settings = try decoder.decode(PlistSettings.self, from: data)
			Log.info("\(mode.plistFilename).plist loaded")
            return settings
        } catch let error {
            Log.error(error)
            fatalError(String(describing: error))
        }
    }

    private func readDataFromMainBundle(name: String) -> Data {
        let bundle = Bundle.main
        guard let fileUrl = bundle.url(forResource: name, withExtension: "plist") else {
            let error = "No file '\(name).plist' in the bundle '\(bundle)' found"
            Log.error(error)
            fatalError(error)
        }
        do {
            let data = try Data(contentsOf: fileUrl)
            return data
        } catch let error {
            Log.error(error)
            fatalError(String(describing: error))
        }
    }
}
