import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.rever.rever/app_icon",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { (call, result) in
      if call.method == "setAppIcon" {
        if let args = call.arguments as? [String: Any],
           let variant = args["variant"] as? String {
          let iconName: String? = (variant == "morning" || variant == "evening") ? variant.capitalized : nil
          UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
              result(FlutterError(code: "ICON_ERROR", message: error.localizedDescription, details: nil))
            } else {
              result(true)
            }
          }
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing variant", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
