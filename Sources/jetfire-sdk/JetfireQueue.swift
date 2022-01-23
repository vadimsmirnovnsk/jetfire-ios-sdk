import Foundation
import UIKit

extension DispatchQueue {
    static let jetfire = DispatchQueue(label: "jetfire.steelhoss.queue", qos: .utility)
}
