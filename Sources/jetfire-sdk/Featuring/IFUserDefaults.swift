import Foundation

public protocol IFUserDefaults: AnyObject {

	var didStartEarly: Bool { get set }
	var showCampaign: [String : Date] { get set }
//	var finishedFeatures: [String] { get set }
	var lastApplicationStartShowDate: Date? { get set }
	var lastPushShowDate: Date? { get set }
	var lastToasterShowDate: Date? { get set }
	var userId: String { get set }
	var pendingNotificationIds: [String] { get set }

}

extension IFUserDefaults {

	func reset() {
		#if DEBUG
		self.didStartEarly = false
		self.showCampaign = [:]
		self.lastApplicationStartShowDate = nil
		self.lastPushShowDate = nil
		self.lastToasterShowDate = nil
		self.pendingNotificationIds = []
		#endif
	}

}

extension UserDefaults: IFUserDefaults {

	/// Jetfire Service
	public var didStartEarly: Bool {
		get { self.bool(forKey: "didStartEarly") }
		set { self.set(newValue, forKey: "didStartEarly"); self.synchronize() }
	}

	/// Featuring
	public var showCampaign: [String : Date] {
		get { return self.dictionary(forKey: "showCampaign") as? [String : Date]  ?? [String : Date]() }
		set { self.set(newValue, forKey: "showCampaign"); self.synchronize() }
	}

	public var lastApplicationStartShowDate: Date? {
		get {
			guard let dateString = self.string(forKey: "lastApplicationStartShowDate") else { return nil }
			return DateFormatter.featuringDateFormatter.date(from: dateString)
		}
		set {
			guard let newValue = newValue else { return }
			let dateString = DateFormatter.featuringDateFormatter.string(from: newValue)
			self.set(dateString, forKey: "lastApplicationStartShowDate")
			self.synchronize()
		}
	}

	public var lastPushShowDate: Date? {
		get {
			guard let dateString = self.string(forKey: "lastPushShowDate") else { return nil }
			return DateFormatter.featuringDateFormatter.date(from: dateString)
		}
		set {
			guard let newValue = newValue else { return }
			let dateString = DateFormatter.featuringDateFormatter.string(from: newValue)
			self.set(dateString, forKey: "lastPushShowDate")
			self.synchronize()
		}
	}

	public var lastToasterShowDate: Date? {
		get {
			guard let dateString = self.string(forKey: "lastToasterShowDate") else { return nil }
			return DateFormatter.featuringDateFormatter.date(from: dateString)
		}
		set {
			guard let newValue = newValue else { return }
			let dateString = DateFormatter.featuringDateFormatter.string(from: newValue)
			self.set(dateString, forKey: "lastToasterShowDate")
			self.synchronize()
		}
	}

	public var userId: String {
		get { return self.string(forKey: "userId") ?? "" }
		set { self.set(newValue, forKey: "userId"); self.synchronize() }
	}

	public var pendingNotificationIds: [String] {
		get { return self.array(forKey: "pendingNotificationIds") as? [String] ?? [String]() }
		set { self.set(newValue, forKey: "pendingNotificationIds"); self.synchronize() }
	}

	public var finishedFeatures: [String] {
		get { return self.array(forKey: "finishedFeatures") as? [String] ?? [String]() }
		set { self.set(newValue, forKey: "finishedFeatures"); self.synchronize() }
	}

}

