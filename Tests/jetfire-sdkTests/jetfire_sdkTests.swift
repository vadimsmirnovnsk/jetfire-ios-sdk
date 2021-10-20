import XCTest
@testable import jetfire_sdk

final class jetfire_sdkTests: XCTestCase {

	func testExample() throws {
		let url = URL(string: "jetfiredemomock://jf?show_story=123123")!
		Jetfire.standard.deeplinkService.application(UIApplication.shared, open: url, options: [:])
		XCTAssertEqual(true, true)
    }

	func testDeeplinkScheme() throws {
		XCTAssertEqual(Jetfire.standard.serviceInfo.deeplinkScheme, "jetfiredemo")
	}

}
