import Foundation

extension JetFireCampaign: CustomDebugStringConvertible {

    public var debugDescription: String {
        "Campaig \(self.id) [\(self.info)]"
    }

    private var info: String {
        var result: [String] = []
        if !self.stories.isEmpty {
            result.append("stories")
        }
        if self.hasToaster {
            result.append("toaster")
        }
        return result.joined(separator: ", ")
    }
}

extension Array where Element == JetFireCampaign{
    public var debugDescription: String {
        self.map { $0.debugDescription }.joined(separator: ", ")
    }
}
