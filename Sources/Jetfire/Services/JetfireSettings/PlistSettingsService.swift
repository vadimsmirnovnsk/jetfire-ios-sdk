import UIKit

protocol IPlistSettingsService: AnyObject {
    var mode: JetfireMode { get set }
    var current: PlistSettings { get }
}

// MARK: - PlistSettingsService

class PlistSettingsService: IPlistSettingsService {

    private lazy var prod: PlistSettings = {
        readAppSettings(mode: .production)
    }()

    private lazy var stage: PlistSettings = {
        readAppSettings(mode: .staging)
    }()

    var current: PlistSettings {
        mode == .production ? prod : stage
    }

    var mode: JetfireMode = .production
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
