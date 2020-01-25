import LiveShopperSDK
import UIKit

enum AlertType {
    case apiError(LiveShopperError)
    case genericNetworkError(String)
    case questionError
    case rewardClaimed
    case taskClaimError

    var message: String {
        switch self {
            case .questionError: return "Unable to answer question"
            case .rewardClaimed: return "Thank you for using LiveShopper"
            case .taskClaimError: return "Unable to claim task"
            case let .apiError(error): return error.message
            case let .genericNetworkError(message): return message
        }
    }

    var title: String {
        switch self {
            case .apiError:
                return "API Error"
            case .rewardClaimed:
                return "Reward Claimed!"
            case .genericNetworkError, .questionError, .taskClaimError:
                return "Error"
        }
    }
}
