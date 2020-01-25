import Foundation
import LiveShopperSDK

class TaskService {
    var tasks: [LSTask] = []
}

extension TaskService: TaskServiceProtocol {
    func fetch(
        latitude: Double,
        longitude: Double,
        radius: Double,
        minimumRadius: Double,
        completion: @escaping (Bool) -> Void
    ) {
        LiveShopper.Tasks.get(
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            minimumRadius: minimumRadius
        ) { result in
            if case let .success(tasks) = result {
                self.tasks = tasks

                NSLog("tasks downloaded.")
                completion(true)
            } else if case let .failure(error) = result, case .networkError = error {
                NSLog("tasks download error \n\n \(error.message)")
                completion(false)
            }
        }
    }
}
