import Foundation

public protocol IPopulatable: Any {
	associatedtype T
	func with(_ populator: (inout T) throws -> Void) rethrows -> T
}

extension IPopulatable {
	public func with(_ populator: (inout T) throws -> Void) rethrows -> T {
		var style = self as! Self.T
		try populator(&style)
		return style
	}
}
