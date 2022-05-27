import Foundation
import JetfireProtobuf

extension Result {

	var unwrapped: Success? {
		return try? self.get()
	}

	var isSuccess: Bool {
		switch self {
			case .success: return true
			default: return false
		}
	}

}

extension Result where Success == Data {

	// Только в этом месте делаем do-catch
	func unwrap<Proto>(to class: Proto.Type) -> Result<Proto, Error> where Proto: Codable {
        Log.info("Will try to unpack codable response: \(self) for class: \(Proto.self)")
		switch self {
			case .success(let data):
				do {
					let object = try JSONDecoder().decode(Proto.self, from: data)
					Log.info("Did successfully unpack codable class: \(Proto.self), object: \(object)")
					return .success(object)
				} catch {
                    Log.info("Unpack codable error: \(error.localizedDescription)")
					return .failure(JetfireError.apiUnwrapDataError)
				}
			case .failure(let error): return .failure(error)
		}
	}

	// Только в этом месте делаем do-catch
	func unwrapProto<Proto>(to protoClass: Proto.Type) -> Result<Proto, Error> where Proto: JetfireProtobuf.Message {
        Log.info("Will try to unpack protobuf response: \(self) for class: \(Proto.self)")
		switch self {
			case .success(let data):
				do {
					let object = try protoClass.init(serializedData: data)
                    Log.info("Did successfully unpack protobuf class: \(Proto.self), object:\n\(object.prettyPrintedJSONString)")
					return .success(object)
				} catch {
                    Log.info("Couldn't unwrap protobuf data: \(data) to class: \(Proto.self)")

                    let cls: JetfireProtobuf.Message.Type = JetFireErrorResponse.self
                    if let errorResponse = try? cls.init(serializedData: data) {
                        Log.info("Unwrap error: \(errorResponse)")
                    }
					return .failure(JetfireError.apiUnwrapDataError)
				}

			case .failure(let error): return .failure(error)
		}
	}

}
