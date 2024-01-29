import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Handle incoming URLs
        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
            self.handle(url)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        self.handle(url)
        return true
    }

    private func handle(_ url: URL) {
        // Check if the URL matches the expected scheme, host, and path prefix
        if url.scheme == "m-samagra", url.host == "kseb.in", url.path.hasPrefix("/sso") {
            // Your code to handle the URL
            debugPrint("Received URL: \(url)")
        }
    }
}
