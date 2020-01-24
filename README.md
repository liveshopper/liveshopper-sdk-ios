![LiveShopper](https://raw.githubusercontent.com/liveshopper/liveshopper-sdk-ios/master/docs/images/logo-small.svg?v=2&sanitize=true)

[LiveShopper](https://liveshopper.com) is the real time insight platform for mobile apps.

## Introduction

Integrate the SDK into your iOS and Android apps to start offering your users real-time, location targeted tasks and offers. The SDK abstracts away cross-platform differences between location services on iOS and Android, allowing you to introduce geofence based context to your apps with just a few lines of code.

The LiveShopper SDK is designed to be unobtrusive to the user and intelligently manage the frequency of tracking to efficently consume battery.

## Authentication

Authenticate using your publishable API key, provided by LiveShopper.

## Configuration

The following entries need to be added to your `Info.plist` file to enable tracking.

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Your iOS 11 and higher background location usage description goes here. e.g., "This app uses your location in the background to recommend places nearby."</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>Your iOS 10 and lower background location usage description goes here. e.g., "This app uses your location in the background to recommend places nearby."</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Your foreground location usage description goes here. e.g., "This app uses your location in the foreground to recommend places nearby."</string>permissions.
```

Then, in your project settings, go to Capabilities > Background Modes and turn on Background fetch. For increased reliability and responsiveness in the background, you should also turn on Location updates.

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>location</string>
</array>
```

## Add SDK to project

The best way to add the SDK to your project is via CocoaPods or Carthage.

### CocoaPods

For CocoaPods, add the following to your Podfile:

```bash
pod 'LiveShopperSDK', '~> 0.0.1'
```

Then, run `pod install`.

### Carthage

To include LiveShopper as a github origin in Carthage, add the following to your Cartfile:

```bash
github "liveshopper/liveshopper-sdk-ios" ~> 0.0.1
```

To include LiveShopper as a binary origin in Carthage, add the following to your Cartfile:

```bash
binary "https://raw.githubusercontent.com/liveshopper/liveshopper-sdk-ios/master/LiveShopperSDK.json" ~> 0.0.1
```

### Add manually

You can also add the SDK to your project manually, though this is not recommended. Download the current release, unzip the package, and drag LiveShopperSDK.framework into your Xcode project. It will automatically appear in the Linked Frameworks and Libraries section of your project settings.

## Dependencies

The SDK depends on Apple’s CoreLocation framework (for location services). In your project settings, go to General > Linked Frameworks and Libraries and add CoreLocation if you haven’t already.

The SDK currently supports iOS 10 and higher.

## Integrate SDK into app

### Initialize SDK

Import the SDK:

```swift
import LiveShopperSDK
```

Initialize the SDK in your AppDelegate class, on the main thread, before calling any other LiveShopper methods. In application(\_:didFinishLaunchingWithOptions:), call:

```swift
LiveShopper.initialize(publishableKey: publishableKey)
```

### Identify user

Until you identify the user, the SDK will automatically identify the user by `deviceId`.

To identify the user when logged in, call:

```swift
LiveShopper.setUserId(userId)
```

where userId is a unique ID for the user. We do not recommend using names, email addresses, etc. for this value.

### Request permissions

The SDK respects the built in iOS location permissions. Before geotracking, the user must authorize location permissions for the app if they haven't previously. This is handled by the SDK once tracking is started.

### Tracking

To start tracking the user's location, call:

```swift
LiveShopper.startTracking()
```

To stop tracking the user's location, call:

```swift
LiveShopper.stopTracking()
```

To listen for events or errors client-side in the background, create a class that implements `LSDelegate`, then call setDelegate().

Set your LSDelegate in a codepath that will be initialized and executed in the background. For example, make your AppDelegate implement LSDelegate, not a ViewController. AppDelegate will be initialized in the background, whereas a ViewController may not be.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate, LSDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    LiveShopper.initialize(publishableKey: publishableKey)
    LiveShopper.setDelegate(self)

    return true
  }

  func didReceiveEvents(_ events: [LSEvent], user: LSUser) {
    // do something with events, user
  }

  func didUpdateLocation(_ location: CLLocation, user: LSUser) {
    // do something with location, user
  }

  func didFail(status: LSStatus) {
    // do something with status
  }
}
```
