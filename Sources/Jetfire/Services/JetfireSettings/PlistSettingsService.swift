import UIKit

protocol IPlistSettingsService {
    var current: PlistSettings { get }
}

// MARK: - PlistSettingsService

class PlistSettingsService: IPlistSettingsService {
    lazy var current: PlistSettings = {
        readAppSettings()
    }()
}

// MARK: - Private

extension PlistSettingsService {

    private func readAppSettings() -> PlistSettings {
        do {
            let decoder = PropertyListDecoder()
            let data = readDataFromMainBundle(name: "JetfireService-Info")
            let settings = try decoder.decode(PlistSettings.self, from: data)
            Log.info("JetfireService-Info.plist loaded")
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
