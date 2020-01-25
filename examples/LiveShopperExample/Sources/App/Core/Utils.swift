import LiveShopperSDK
import UIKit

class Utils {
    static func getUserId() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }

    static func stringForEvent(_ event: LSEvent) -> String {
        switch event.type {
            case .userEnteredGeofence:
                return "Entered geofence \(event.geofence != nil ? event.geofence!.description : "-")"
            case .userStartedTraveling:
                return "Started traveling"
            case .userStoppedTraveling:
                return "Stopped traveling"
            case .userExitedGeofence:
                return "Exited geofence \(event.geofence != nil ? event.geofence!.description : "-")"
            default:
                return "-"
        }
    }

    static func stringForStatus(_ status: LSStatus) -> String {
        switch status {
            case .success: return "Success"
            case .errorLocation: return "Location Error"
            case .errorNetwork: return "Network Error"
            case .errorPermissions: return "Permissions Error"
            case .errorPublishableKey: return "Publishable Key Error"
            case .errorServer: return "Server Error"
            case .errorUnauthorized: return "Unauthorized Error"
            default: return "Unknown Error"
        }
    }
}
