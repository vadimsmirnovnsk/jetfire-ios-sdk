import Foundation

public protocol IUserDefaults: AnyObject {

	var readStories: [String : Date] { get set }

}

extension UserDefaults: IUserDefaults {

	public var readStories: [String : Date] {
		get { return self.dictionary(forKey: "readStories") as? [String : Date]  ?? [String : Date]() }
		set { self.set(newValue, forKey: "readStories"); self.synchronize() }
	}

}
