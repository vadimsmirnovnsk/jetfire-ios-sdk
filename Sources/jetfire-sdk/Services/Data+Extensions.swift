import Foundation

extension Data {
    /// Строка с форматированным JSON, пригодная для распечатывания в консоль
    var prettyPrintedJSONString: NSString {
        if let jObject = try? JSONSerialization.jsonObject(with: self, options: []) {
            let data = try? JSONSerialization.data(
                withJSONObject: jObject,
                options: [.prettyPrinted, .withoutEscapingSlashes]
            )
            let result = NSString(data: data ?? Data(), encoding: String.Encoding.utf8.rawValue)
            return result ?? "<Not UTF-8>"
        }
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) ?? "<Not UTF-8>"
    }
}
