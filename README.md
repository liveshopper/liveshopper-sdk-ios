[![CocoaPods](https://img.shields.io/cocoapods/v/LiveShopperSDK.svg)](https://cocoapods.org/pods/LiveShopperSDK)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)

[LiveShopper](https://liveshopper.com)

See additional docs: [iOS Documentation](https://docs.liveshopper.dev/sdk/ios/index.html)

## Introduction

Integrate the SDK into your iOS applications to start offering your users real-time, location targeted tasks and offers. The LiveShopper SDK
is designed to be unobtrusive to the user and intelligently manage the frequency of tracking to manage battery consumption.

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

Then, in your project settings, go to Capabilities > Background Modes and turn on Background fetch. For increased reliability and
responsiveness in the background, you should also turn on Location updates.

```xml
<key>UIBackgroundModes</key>
<array>
<string>fetch</string>
<string>location</string>
</array>
```

## Add SDK to project

The best way to add the SDK to your project is via CocoaPods.

### CocoaPods

For CocoaPods, add the following to your `Podfile`:

```bash
pod 'LiveShopperSDK', '~> 0.1.1'
```

Then, run `pod install`.

### Carthage

To include LiveShopper as a Github origin in Carthage, add the following to your `Cartfile`:

```bash
github "liveshopper/liveshopper-sdk-ios"  ~> 0.1.1
```

To include LiveShopper as a binary origin in Carthage, add the following to your `Cartfile`:

```bash
binary "https://raw.githubusercontent.com/liveshopper/liveshopper-sdk-ios/master/LiveShopperSDK.json"  ~> 0.1.1
```

### Add manually

You can also add the SDK to your project manually, though this is not recommended. Download the current release, unzip the package, and drag
`LiveShopperSDK.framework` into your Xcode project. It will automatically appear in the _Linked Frameworks and Libraries_ section of your
project settings.

## Dependencies

The SDK depends on Apple’s [CoreLocation](https://developer.apple.com/documentation/corelocation/) framework (for location services). In
your project settings, go to _General > Linked Frameworks and Libraries_ and add _CoreLocation_ if you haven’t already.

The SDK currently supports iOS 10 and higher.

## Integrate SDK into app

### Initialize SDK

Import the SDK:

```swift
import  LiveShopperSDK
```

Initialize the SDK in your AppDelegate class, on the main thread, before calling any other LiveShopper methods, call:

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

The SDK respects the built in iOS location permissions. Before tracking is permitted, the user must authorize location permissions for the
app if they haven't previously. This is handled by the SDK once tracking is started.

### Tracking

To start tracking the user's location, call:

```swift
let options = LiveShopperTrackingOptions.RESPONSIVE
options.sync = .ALL
options.showBlueBar = true

LiveShopper.Tracking.start(options: options)
```

To stop tracking the user's location, call:

```swift
LiveShopper.Tracking.stop()
```

To listen for events or errors client-side in the background, create a class that implements `LSDelegate`, then call `setDelegate()`.

Set your `LSDelegate` where it will be initialized and executed in the background.

For example, make your `AppDelegate` implement `LSDelegate`, not a `ViewController`.

`AppDelegate` will be initialized in the background, whereas a `ViewController` may not be.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate, LSDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let publishableKey = "XXXXXX" // replace with your publishable API key

        LiveShopper.initialize(publishableKey: publishableKey)
        LiveShopper.setDelegate(self)

        return true
    }

    func onClientLocationUpdated(location: CLLocation, stopped: Bool, source: LiveShopper.LSLocationSource) {
        //
    }

    func onError(status: LiveShopper.LSStatus) {
        //
    }

    func onEventsReceived(events: [LSEvent], user _: LSUser) {
        //
    }

    func onLocationUpdated(location: CLLocation, user: LSUser) {
        //
    }

    func onLog(message: String) {
        //
    }
}
```

<!--
### Tasks

The LiveShopper SDK uses the `LSTask` model to represent an activity that can be performed by the user.

`LSTask` provides the following information:

```json
{
    "count": 22,
    "data": [
        {
            "state": "generated",
            "description": "Determine if location exists",
            "distance": 0.41139203933289425,
            "due": "4102376400",
            "title": "Location Verification",
            "claimDistanceOverride": "0.5",
            "locationKey": "-LmfCNwykkNhhXEOYSB_",
            "logo": "",
            "taskRequirements": null,
            "associatesOnly": false,
            "nextQuestion": "-LmjvVzwDrCMSoYmz_7x",
            "location": {
                "latitude": 41.0388157,
                "longitude": -83.6532543,
                "address1": "229 W MAIN CROSS ST",
                "address2": "",
                "city": "FINDLAY",
                "country": "US",
                "name": "FINDLAY MAIN OFFICE",
                "phoneNumber": "",
                "state": "OH",
                "zipCode": "45840"
            },
            "owners": {
                "user": "...",
                "client": "...",
                "campaign": "-LmjvUny5xtQdOU3COwF"
            },
            "questions": [
                {
                    "type": "singleAnswer",
                    "order": 0,
                    "images": null,
                    "owners": {
                        "client": "..."
                    },
                    "answers": [
                        {
                            "key": "-LmjvOS4y20duzH218WI",
                            "score": null,
                            "created": null,
                            "modified": null,
                            "answerOrder": 0,
                            "displayText": "Yes",
                            "questionKey": "-LmjvVzwDrCMSoYmz_7x",
                            "displayTextKey": null,
                            "clientReference": null,
                            "photoCaptureOptions": null
                        },
                        {
                            "key": "-LmjvQr5tYxA_dJftZRY",
                            "score": null,
                            "created": null,
                            "modified": null,
                            "answerOrder": 1,
                            "displayText": "No",
                            "questionKey": "-LmjvVzwDrCMSoYmz_7x",
                            "displayTextKey": null,
                            "clientReference": null,
                            "photoCaptureOptions": null
                        }
                    ],
                    "created": 1566319710,
                    "videoId": null,
                    "hasOther": false,
                    "maxScore": 0,
                    "maxValue": null,
                    "minValue": null,
                    "modified": 1569872078,
                    "numStars": null,
                    "pointers": {
                        "previousKey": null,
                        "nextKey": ""
                    },
                    "question": "Is this location an actual post office?",
                    "parentKey": "-LmjvVzwDrCMSoYmz_7x",
                    "isOptional": false,
                    "answerOrder": "sorted",
                    "allowDecimals": true,
                    "lowValueLabel": null,
                    "responseCount": null,
                    "sentimentText": null,
                    "highValueLabel": null,
                    "scoreIntervals": null,
                    "clientReference": "",
                    "criticalAnswers": null,
                    "showUnitsOnLeft": false,
                    "thresholdAnswers": null,
                    "maxMultipleAnswers": null,
                    "minMultipleAnswers": null,
                    "mustPickSuggestion": null,
                    "singleLineResponse": null,
                    "openTextPlaceholder": null,
                    "openTextSuggestions": null,
                    "photoCaptureOptions": {
                        "photoLevelType": "none",
                        "allowFlashToggle": true,
                        "mustProvidePhoto": false,
                        "photoOverlayType": "none",
                        "defaultFlashState": false
                    },
                    "unitOfMeasurementLabel": null,
                    "lastAnswerPositionPinned": null
                }
            ],
            "rewards": [
                {
                    "logo": "",
                    "state": "",
                    "owners": {
                        "client": "..."
                    },
                    "created": 1565199354,
                    "message": {
                        "body": "Stop by LiveShopper for your FREE high five!",
                        "header": "High Five"
                    },
                    "legalese": "",
                    "modified": 1565199354,
                    "parentKey": "-Llh8g_IkORyRb3d7G0I",
                    "claimCount": 0,
                    "maxClaimCount": 0,
                    "usedClaimCount": 0,
                    "activationDelay": 0,
                    "clientReference": "",
                    "campaignRewardKey": "-Llh8g_IkORyRb3d7G0I",
                    "activationExpiration": 1,
                    "redemptionExpiration": 30
                }
            ],
            "time": {
                "max": 5,
                "min": 3
            }
        }
    ]
}
```

You can search for nearby tasks by calling:

```swift
LiveShopper.Tasks.get(
    latitude: Double,
    longitude: Double,
    radius: Double,
    minimumRadius: Double
) { result in
    if case let .success(tasks) = result {
        ...
    } else if case let .failure(error) = result {
        ...
    }
}
```

You can get the available tasks at a location by calling:

```swift
LiveShopper.Tasks.get(
    locationID: String,
    minimumRadius: Double?,
    campaignID: String?
) { result in
    if case let .success(tasks) = result {
        ...
    } else if case let .failure(error) = result {
        ...
    }
}
```

You can get details about what the user must do to satisfy the task by calling:

```swift
let requirements = LiveShopper.Tasks.getRequirements(task: LSTask)
```

You can claim a task for the current user by calling:

```swift
LiveShopper.Tasks.claim(task: LSTask) { result in
    if  case  let .success(claimedTask) = result {
        ...
    } else if  case  let .failure(error) = result
        ...
    }
}
```

You can send a user response related to a task by calling:

```swift
LiveShopper.Tasks.saveResponse(
    task: LSTask,
    question: LSQuestion,
    answers: [String]?,
    userAnswer: String?,
    image: UIImage?,
) { result in
    if  case  let .success(response) = result {
        ...
    else  if  case  let .failure(error) = result {
        ...
    }
}
```

Finally, there is a helper method to get the next step in a task by calling:

```swift
let question = LiveShopper.Tasks.nextQuestion(task: LSTask, key: String)
```

### Places

The LiveShopper SDK uses the `LSPlace` model to represent physical locations you have created.

`LSPlace` provides the following information:

```json
{
    "name": "FINDLAY MAIN OFFICE",
    "active": true,
    "latitude": 41.0388157,
    "longitude": -83.6532543,
    "address1": "229 W MAIN CROSS ST",
    "address2": "",
    "city": "FINDLAY",
    "state": "OH",
    "country": "US",
    "zipCode": "45840",
    "clientReference": "",
    "emails": [],
    "logoKey": "",
    "phoneNumber": ""
}
```

You can search for nearby `LSPlace` by calling:

```swift
LiveShopper.Places.get(
    latitude: Double,
    longitude: Double,
    radius: Double,
    minimumRadius: Double
) { result in
    if case .success = result {
        ...
    } else if case let .failure(error) = result {
        ...
    }
}
```

alternatively, you can query based on keyword:

```swift
LiveShopper.Places.get(searchTerm: String) { result in {
    if case .success = result {
        ...
    } else if case let .failure(error) = result {
        ...
    }
}
```

### Rewards

The LiveShopper SDK uses the `LSReward` model to represent what the user receives for completing a task.

`LSReward` provides the following information:

```json
{
    "logo": "",
    "state": "",
    "owners": {
        "client": "..."
    },
    "created": 1565199354,
    "message": {
        "body": "Stop by LiveShopper for your FREE high five!",
        "header": "High Five"
    },
    "legalese": "",
    "modified": 1565199354,
    "parentKey": "-Llh8g_IkORyRb3d7G0I",
    "claimCount": 0,
    "maxClaimCount": 0,
    "usedClaimCount": 0,
    "activationDelay": 0,
    "clientReference": "",
    "campaignRewardKey": "-Llh8g_IkORyRb3d7G0I",
    "activationExpiration": 1,
    "redemptionExpiration": 30
}
```

You can claim a `LSReward` by calling:

```swift
LiveShopper.Rewards.claim(
    task: LSTask,
    reward: LSReward
) { result in
    if case .success = result {
        ...
    } else if case let .failure(error) = result {
        ...
    }
}
``` -->
