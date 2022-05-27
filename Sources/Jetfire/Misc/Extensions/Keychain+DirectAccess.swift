import JetfireKeychainAccess
import Foundation

extension Keychain {

	func getDirect(_ key: String) -> String? {
		do {
			return try self.getString(key)
		} catch {
			let msg = "Keychain getter error for key:\(key). Error: \(error)"
            assertionFailure(msg)
			return nil
		}
	}

	func setDirect(_ value: String, key: String) {
		do {
			try self.set(value, key: key)
		} catch {
			let msg = "Keychain setter error for key:\(key). Error: \(error)"
            assertionFailure(msg)
		}
	}

	func getBool(_ key: String) -> Bool {
		do {
			let boolString = try self.getString(key)
			return boolString?.boolValue ?? false
		} catch {
			let msg = "Keychain getter error for key:\(key). Error: \(error)"
            assertionFailure(msg)
			return false
		}
	}

	func setBool(_ value: Bool, key: String) {
		do {
			try self.set(value.stringValue, key: key)
		} catch {
			let msg = "Keychain setter error for key:\(key). Error: \(error)"
            assertionFailure(msg)
		}
	}

	func getDirectData(_ key: String) -> Data? {
		do {
			let data = try self.getData(key)
			return data
		} catch {
			let msg = "Keychain getter error for key:\(key). Error: \(error)"
            assertionFailure(msg)
			return nil
		}
	}

	func setDirectData(_ value: Data, key: String) {
		do {
			try self.set(value, key: key)
		} catch {
			let msg = "Keychain setter error for key:\(key). Error: \(error)"
			assertionFailure(msg)
		}
	}

}

fileprivate extension Bool {

	var stringValue: String {
		return self ? "true" : "false"
	}

}

extension String {

	var boolValue: Bool {
		return self == "true"
	}

}
