import CoreLocation
import LiveShopperSDK
import UIKit
import UserNotifications

enum SDKState {
    case authenticated
    case unauthenticated
    case loading
    case loaded
}

protocol SDKHandler: class {
    func load()
}

class ViewController: UIViewController {
    @IBOutlet var mainView: UIView!
    @IBOutlet var toastView: UIView!

    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        requestPermissions()
        setupGeofencing()

        load()
    }

    public func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    private func requestPermissions() {
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }

        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (didAllow: Bool, error: Error?) in
            if error != nil {
                NSLog("Permissions Error: \(String(describing: error))")
            } else if !didAllow {
                NSLog("User has declined notifications")
            }
        }

        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                NSLog("User has turned off notifications")
            }
        }

        notificationCenter.delegate = self
    }

    private func setupGeofencing() {
        LiveShopper.startTracking()
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let content = response.notification.request.content

        guard
            let locationID = content.userInfo[LiveShopper.GeofenceNotificationUserInfoKey.LocationID] as? String,
            let campaignID = content.userInfo[LiveShopper.GeofenceNotificationUserInfoKey.CampaignID] as? String
        else {
            completionHandler()
            return
        }

        LiveShopper.Tasks.get(locationID: locationID, minimumRadius: AppConstants.defaultRadius, campaignID: campaignID) { result in
            if case let .success(tasks) = result {
                self.tasksOpened(tasks: tasks)
                completionHandler()
            } else if case let .failure(error) = result, case .networkError = error {
                NSLog("tasks download error \n\n \(error.message)")
                completionHandler()
            }
        }
    }
}

extension ViewController: SDKHandler {
    func load() {
        App.shared.delegateService.notify(state: .loading)

        getLocations()
        getTasks()
    }

    private func getLocations(radius: Double? = nil, minimumRadius: Double? = nil) {
        let location = locationManager.location
        let latitude = location?.coordinate.latitude ?? 0
        let longitude = location?.coordinate.longitude ?? 0
        let radius = radius ?? AppConstants.defaultRadius
        let min = minimumRadius ?? 0

        App.shared.placeService.fetch(
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            minimumRadius: min
        ) { result in
            if result {
                App.shared.delegateService.notify(state: .loaded)
            }
        }
    }

    private func getTasks(radius: Double? = nil, minimumRadius: Double? = nil) {
        let location = locationManager.location
        let latitude = location?.coordinate.latitude ?? 0
        let longitude = location?.coordinate.longitude ?? 0
        let radius = radius ?? AppConstants.defaultRadius
        let min = minimumRadius ?? 0

        App.shared.taskService.fetch(
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            minimumRadius: min
        ) { result in
            if result {
                self.toastView.isHidden = true
                App.shared.delegateService.notify(state: .loaded)
            } else {
                self.getTasks()
            }
        }
    }

    private func tasksOpened(tasks: [LSTask]?) {
        if
            let newTasks = tasks,
            let task = newTasks.first,
            let viewController = storyboard?.taskOverviewViewController(task: task),
            let tabVC = children.compactMap({ $0 as? UITabBarController }).first,
            let navVC = tabVC.selectedViewController as? UINavigationController {
            navVC.pushViewController(viewController, animated: true)
        } else {
            let viewController = UIAlertController(
                title: "Failed to open task",
                message: nil,
                preferredStyle: .alert
            )

            viewController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            present(viewController, animated: true, completion: nil)
        }
    }
}
