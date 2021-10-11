internal protocol IEventBuilder {

	@discardableResult func name(_ name: EventId) -> IEventBuilder
	@discardableResult func string(_ name: String) -> IEventBuilder
	@discardableResult func param(_ param: ParameterId, value: Any?) -> IEventBuilder

}

internal final class AnalyticsEventBuilder: IEventBuilder {

	public private(set) var name: String? = nil
	public private(set) var params: [ String : Any ] = [:]

	public init() {}

	@discardableResult internal func name(_ name: EventId) -> IEventBuilder {
		self.name = name.rawValue
		return self
	}

	@discardableResult internal func string(_ name: String) -> IEventBuilder {
		self.name = name
		return self
	}

	@discardableResult internal func param(_ param: ParameterId, value: Any?) -> IEventBuilder {
		self.params[param.rawValue] = value
		return self
	}

}
