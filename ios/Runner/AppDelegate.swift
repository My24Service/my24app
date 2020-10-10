import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegatem,UIResponder,UIApplicationDelegate {
  func application(_ application:UIApplication,didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey:Any]?)->Bool{
      // Other intialization code…
      UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))

      return true
  }
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
