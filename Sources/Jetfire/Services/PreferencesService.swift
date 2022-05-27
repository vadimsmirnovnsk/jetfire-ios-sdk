import JetfireKeychainAccess
import Foundation

final class PreferencesService {

	private enum C {
		static let userIdKey = "jetfireUserIdKey"
	}

	lazy var sessionId = APISessionId(rawValue: UUID.uppercased())

	private let keychain: Keychain

	lazy var userId: APIUserId = { [unowned self] in
		if let retrievedUserId = self.migrateValue(for: C.userIdKey) {
			let retrievedApiUserId = APIUserId(rawValue: retrievedUserId)
			return retrievedApiUserId
		}

		let newUserId = UUID.uppercased()
		self.set(value: newUserId, key: C.userIdKey)
		let apiUserId = APIUserId(rawValue: newUserId)

        Log.info("Jetfire did create new user id")

		return apiUserId
	}()

	func logout() {
		self.set(value: nil, key: C.userIdKey)
	}

	func resetUser() {
		self.set(value: nil, key: C.userIdKey)
	}

	init() {
		let keychainId = "xyz.jetfire.\(Constants.bundleID)"
        Log.info("Jetfire is using keychain id: \(keychainId)")
		self.keychain = Keychain(service: keychainId)
			.accessibility(.afterFirstUnlock)
			.synchronizable(true)
	}

	// MARK: Private

	private func migrateValue(for key: String) -> String? {
		return self.keychain.getDirect(key)
//		var value = self.ud.string(forKey: key)
//		if value == nil {
//			if let keychainValue = self.keychain.getDirect(key) {
//				self.set(value: keychainValue, key: key)
//				try? self.keychain.remove(key)
//				value = keychainValue
//				log.info("Migrate user for key: \(key)")
//			}
//		}
//		return value
	}

	private func set(value: String?, key: String) {
		if let value = value {
			self.keychain.setDirect(value, key: key)
		} else {
			try? self.keychain.remove(key)
		}
	}

	private func randomString(length: Int) -> String {
		let approvedCharacters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
		let randomString = String((0..<length).map { _ in approvedCharacters[Int(arc4random_uniform(UInt32(approvedCharacters.count)))]})
		return randomString
	}

}

extension UUID {

	static func uppercased() -> String {
		return UUID().uuidString.uppercased()
	}

	var notEmptyUUID: String? {
		let notEmptyString = (self.uuidString as NSString).trimmingCharacters(in: CharacterSet(charactersIn: "0-"))
		if notEmptyString.isEmpty {
			return nil
		}
		return self.uuidString
	}

}
