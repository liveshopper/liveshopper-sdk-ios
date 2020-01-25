import LiveShopperSDK

protocol TaskServiceProtocol {
    var tasks: [LSTask] { get set }

    func fetch(
        latitude: Double,
        longitude: Double,
        radius: Double,
        minimumRadius: Double,
        completion: @escaping (Bool) -> Void
    )
}
