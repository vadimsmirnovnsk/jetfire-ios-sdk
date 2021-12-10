extension Int64 {

	var string: String { String(self) }
	var eventType: JetFireEventType { JetFireEventType.with { $0.value = self } }
}
