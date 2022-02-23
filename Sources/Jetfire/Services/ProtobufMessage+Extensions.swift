import Foundation
import SwiftProtobuf

extension SwiftProtobuf.Message {
    /// Строка с форматированным JSON, пригодная для распечатывания в консоль
    var prettyPrintedJSONString: NSString {
        (try? self.jsonUTF8Data().prettyPrintedJSONString) ?? "<Not UTF-8>"
    }
}
