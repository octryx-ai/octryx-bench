import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerShareChannel(engineBridge)
  }

  /// Offers the system share sheet for the JSON export.
  private func registerShareChannel(_ engineBridge: FlutterImplicitEngineBridge) {
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ShareChannel") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "ch.octryx.kaffee_begleiter/share",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "shareFile" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let args = call.arguments as? [String: Any],
        let fileName = args["fileName"] as? String,
        let content = args["content"] as? String
      else {
        result(FlutterError(code: "bad_args", message: "fileName and content are required", details: nil))
        return
      }
      do {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try content.write(to: url, atomically: true, encoding: .utf8)
        let sheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        guard
          let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else {
          result(FlutterError(code: "no_view", message: "No view controller to present from", details: nil))
          return
        }
        if let popover = sheet.popoverPresentationController {
          popover.sourceView = root.view
          popover.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.midY, width: 0, height: 0)
          popover.permittedArrowDirections = []
        }
        root.present(sheet, animated: true)
        result(true)
      } catch {
        result(FlutterError(code: "share_failed", message: error.localizedDescription, details: nil))
      }
    }
  }
}
