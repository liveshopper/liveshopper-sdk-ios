import LiveShopperSDK
import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet var loadingText: UILabel!

    var state: SDKState = .loading {
        willSet(newState) {
            update(newState)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        App.shared.delegateService.register(delegate: self)
    }
}

extension LoadingViewController {
    struct Constants {
        static let Done = "Done!"
        static let DownloadingTasks = "Downloading Tasks..."
        static let LoggingIn = "Logging In..."
        static let RefreshText = "Refreshing Session..."
    }
}

extension LoadingViewController: SDKDelegate {
    func update(_ newState: SDKState) {
        switch (state, newState) {
            case (.loading, .loading): toLoading()
            case (.loading, .loaded), (.loaded, .loaded): toLoaded()
            default: fatalError("Transition from \(state) to \(newState) unsupported.")
        }
    }

    private func toLoaded() {
        updateLabel()
    }

    private func toLoading() {
        updateLabel()
    }

    private func updateLabel() {
        loadingText.text = LiveShopper.isAuthenticated() ? Constants.DownloadingTasks : Constants.LoggingIn
    }
}
