import UIKit

enum Constants {

	#if DEBUG
	static let timeoutIntervalForRequest: TimeInterval = 60
	static let timeoutIntervalForResource: TimeInterval = 300
	#else
	static let timeoutIntervalForRequest: TimeInterval = 60
	static let timeoutIntervalForResource: TimeInterval = 300
	#endif

	static let verboseVersion = String(format: "Version %@ (%@)", Constants.currentVersion, Constants.currentBuild)
	static let appVersion = String(format: "%@.%@", Constants.currentVersion, Constants.currentBuild)
	// swiftlint:disable:next force_cast
	static let currentBuild = Bundle.main.infoDictionary?[String(kCFBundleVersionKey)]! as! String
	// swiftlint:disable:next force_cast
	static let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]! as! String

	static let bundleID = Bundle.main.bundleIdentifier ?? "unknown"
	static let mobilePlatformModel = UIDeviceHardware.platformModelString()
	static let mobilePlatformVerboseModel = UIDeviceHardware.platformString()
	static let mobileOSName = "ios"
	static let mobileVendorName = "Apple"
	static let platformOSVersion = UIDevice.current.systemVersion
	static let currentLocale = Locale.current.identifier
	static let currentTimeZone = TimeZone.current.identifier

    static var currentLanguage: String {
        let language = Locale.preferredLanguages.first
        return language?.split(separator: "-").first.map { String($0) } ?? "en"
    }

}
