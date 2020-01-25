import CoreLocation
import LiveShopperSDK
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let publishableKey = AppConstants.publishableKey // replace with your publishable API key
        let userId = Utils.getUserId()

        LiveShopper.initialize(publishableKey: publishableKey)
        LiveShopper.setUserId(userId)
        LiveShopper.setDelegate(self)

        return true
    }

    func applicationDidBecomeActive(_: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidEnterBackground(_: UIApplication) {}

    func applicationWillEnterForeground(_: UIApplication) {}

    func applicationWillResignActive(_: UIApplication) {}

    func applicationWillTerminate(_: UIApplication) {}
}

extension AppDelegate: LSDelegate {
    func didFailWithStatus(status: LSStatus) {
        let statusString = Utils.stringForStatus(status)
        sendNotification(title: "Error", body: statusString)
    }

    func didReceiveEvents(_ events: [LSEvent], user _: LSUser) {
        for event in events {
            switch event.type {
                case .userEnteredGeofence:
                    guard
                        let tasks = event.tasks,
                        let task = tasks.first,
                        let region = event.region
                    else {
                        return
                    }

                    sendTaskNotification(task: task, region: region)
                default:
                    let eventString = Utils.stringForEvent(event)
                    sendNotification(title: "Event", body: eventString)
            }
        }
    }

    func didUpdateLocation(_ location: CLLocation, user: LSUser) {
        let state = user.stopped ? "Stopped at" : "Moved to"
        let locationString = "\(state) location (\(location.coordinate.latitude), " +
            "\(location.coordinate.longitude)) with accuracy " +
            "\(location.horizontalAccuracy) meters"

        sendNotification(title: "Location", body: locationString)

        updateTasks(location)
    }

    private func updateTasks(_ location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let radius = AppConstants.defaultRadius
        let min = 0.0

        App.shared.taskService.fetch(
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            minimumRadius: min
        ) { result in
            if result {
                App.shared.delegateService.notify(state: .loaded)
            } else {
                self.updateTasks(location)
            }
        }
    }

    private func sendNotification(title: String, body: String) {
        NSLog("\(title): \(body)")

        let content = UNMutableNotificationContent()
        content.badge = 1
        content.body = body
        content.sound = UNNotificationSound.default
        content.title = title

        let identifier = UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request, withCompletionHandler: { error in
            if error != nil {
                print("Error \(error?.localizedDescription ?? "error")")
            }
        })
    }

    private func sendTaskNotification(task: LSTask, region _: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = "\(task.location.name) Task available!"
        content.body = "Tap here to see this task and more near you"
        content.sound = UNNotificationSound.default

        var userInfo = [String: Any]()
        userInfo[LiveShopper.GeofenceNotificationUserInfoKey.LocationID] = task.locationKey
        userInfo[LiveShopper.GeofenceNotificationUserInfoKey.CampaignID] = task.owners?.campaign
        content.userInfo = userInfo

        let identifier = UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if error != nil {
                print("Error \(error?.localizedDescription ?? "error")")
            }
        }
    }
}
