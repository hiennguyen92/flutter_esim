import Flutter
import UIKit

public class FlutterEsimPlugin: NSObject, FlutterPlugin {
    
    public private(set) static var sharedInstance: FlutterEsimPlugin!
    
    private var streamHandlers: WeakArray<EventCallbackHandler> = WeakArray([])
    
    private var esimChecker: EsimChecker
    
    private func sendEvent(_ event: String, _ body: [String : Any?]?) {
        streamHandlers.reap().forEach { handler in
            handler?.send(event, body ?? [:])
        }
    }
    
    private static func createMethodChannel(messenger: FlutterBinaryMessenger) -> FlutterMethodChannel {
        return FlutterMethodChannel(name: "flutter_esim", binaryMessenger: messenger)
    }
    
    private static func createEventChannel(messenger: FlutterBinaryMessenger) -> FlutterEventChannel {
        return FlutterEventChannel(name: "flutter_esim_events", binaryMessenger: messenger)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterEsimPlugin()
        instance.shareHandlers(with: registrar)
    }
    
    private func shareHandlers(with registrar: FlutterPluginRegistrar) {
        registrar.addMethodCallDelegate(self, channel: Self.createMethodChannel(messenger: registrar.messenger()))
        let eventsHandler = EventCallbackHandler()
        esimChecker.handler = eventsHandler;
        self.streamHandlers.append(eventsHandler)
        Self.createEventChannel(messenger: registrar.messenger()).setStreamHandler(eventsHandler)
    }
    
    public override init() {
        esimChecker = EsimChecker()
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isSupportESim":
            let args = call.arguments as? [String];
            result(esimChecker.isSupportESim(supportedModels: args ?? []));
            break;
        case "installEsimProfile":
            guard let args = call.arguments else {
                result("OK")
                return
            }
            if let getArgs = args as? [String: Any] {
                esimChecker.installEsimProfile(
                    address: getArgs["profile"] as? String ?? "",
                    matchingID: getArgs["matchingID"] as? String,
                    oid: getArgs["oid"] as? String,
                    confirmationCode: getArgs["confirmationCode"] as? String,
                    iccid: getArgs["iccid"] as? String,
                    eid: getArgs["eid"] as? String)
            }
            result("OK")
            break;
        case  "instructions":
            result(
                "1. Save QR Code\n" +
                "2. On your device, go to Settings\n" +
                "3. Tap Cellular or Mobile\n" +
                "4. Tap Add Cellular Plan or Add Mobile Data Plan\n" +
                "5. Tap Add eSIM\n" +
                "6. Tap Use QR Code\n" +
                "7. Tap Open Photos\n" +
                "8. Tap Open Photos\n" +
                "9. SELECT the saved QR code\n" +
                "10. TAP Continue twice\n" +
                "11. WAIT a few minutes for your eSIM to activate\n" +
                "12. TAP Done"
            )
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

class EventCallbackHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    public func send(_ event: String, _ body: Any) {
        let data: [String : Any] = [
            "event": event,
            "body": body
        ]
        eventSink?(data)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

