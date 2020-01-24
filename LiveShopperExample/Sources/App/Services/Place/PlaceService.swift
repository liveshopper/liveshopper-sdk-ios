import Foundation
import LiveShopperSDK

class PlaceService {
    var places: [LSPlace] = []
}

extension PlaceService: PlaceServiceProtocol {
    func fetch(
        latitude: Double,
        longitude: Double,
        radius: Double,
        minimumRadius: Double,
        completion: @escaping (Bool) -> Void
    ) {
        LiveShopper.Places.get(
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            minimumRadius: minimumRadius
        ) { result in
            if case let .success(places) = result {
                self.places = places

                NSLog("locations downloaded.")
                completion(true)
            } else if case let .failure(error) = result, case .networkError = error {
                NSLog("location download error \n\n \(error.message)")
                completion(false)
            }
        }
    }
}
