import Foundation
import LiveShopperSDK

class App {
    static let shared = App()

    var delegateService: DelegateServiceProtocol
    var placeService: PlaceServiceProtocol
    var taskService: TaskServiceProtocol

    private init() {
        delegateService = DelegateService()
        placeService = PlaceService()
        taskService = TaskService()
    }
}
