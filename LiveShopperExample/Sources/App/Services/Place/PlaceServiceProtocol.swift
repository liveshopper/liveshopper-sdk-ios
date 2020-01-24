import LiveShopperSDK

protocol PlaceServiceProtocol {
    var places: [LSPlace] { get set }

    func fetch(
        latitude: Double,
        longitude: Double,
        radius: Double,
        minimumRadius: Double,
        completion: @escaping (Bool) -> Void
    )
}
