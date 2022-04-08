import UIKit
import Jetfire

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

//		FirebaseApp.configure()

		self.window = UIWindow()
		let nc = UINavigationController(rootViewController: ViewController())
		self.window?.rootViewController = nc
		self.window?.makeKeyAndVisible()

        Jetfire.standard.appendLogTracker(ConsoleLogTracker())

		Jetfire.standard.start(mode: .staging)
        Jetfire.standard.enableFeaturing()

//		let text = NegativeReviewCommentGenerator().generate(for: "John")
//		print("Generated text:\n\(text)")

//		self.requestPushes()

		return true
	}

	func requestPushes() {
//		UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .badge, .sound ]) { (granted, error) in
//			if let error = error { print("Did receive register notification error: \(error)") }
//			DispatchQueue.main.async { Jetfire.standard.updatePushStatus(granted: granted) }
//		}
//
//		UNUserNotificationCenter.current().delegate = self
	}

}

extension AppDelegate: UNUserNotificationCenterDelegate {

	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		willPresent notification: UNNotification,
		withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void
	) {
		completionHandler(.banner)
	}

	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse,
		withCompletionHandler completionHandler: @escaping () -> Void
	) {
//		Jetfire.standard.userNotificationCenter(center, didReceive: response)
		completionHandler()
	}

}
