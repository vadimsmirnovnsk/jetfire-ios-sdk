import JetfireProtobuf
import Foundation

extension JetFireErrorResponse: LocalizedError {

	public var errorDescription: String? {
		#if DEBUG
		let finalMessage = "\(self.code): \(self.message)\n\(self.systemMessage)"
		return finalMessage
		#else
		return self.message
		#endif
	}

}
