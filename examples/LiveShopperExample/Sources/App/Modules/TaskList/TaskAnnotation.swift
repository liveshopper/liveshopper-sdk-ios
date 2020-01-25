import LiveShopperSDK
import MapKit
import UIKit

class TaskAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let task: LSTask

    init(task: LSTask) {
        self.task = task
        coordinate = self.task.location.coordinate
        super.init()
    }
}

extension LSPlace {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
