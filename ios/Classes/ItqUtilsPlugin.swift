import Flutter
import UIKit

public class ItqUtilsPlugin: NSObject, FlutterPlugin {
  var packInfo = [String: String]()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "itq_utils", binaryMessenger: registrar.messenger())
    let instance = ItqUtilsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "packageInfo":
      self.packInfo = [
            "appName": Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "",
            "packageName": Bundle.main.bundleIdentifier ?? "",
            "versionCode": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "",
            "versionName": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        ]
      result(packInfo) // Return the dictionary here
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
