import LiveShopperSDK
import UIKit

class AlertPresenter {
    static func presentAlert(type: AlertType) {
        if let alertVC = topLevelViewController() as? UIAlertController {
            alertVC.dismiss(animated: true) {
                self.presentAlert(type: type)
            }

        } else {
            let alertVC = UIAlertController(
                title: type.title,
                message: type.message,
                preferredStyle: UIAlertController.Style.alert
            )

            alertVC.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertAction.Style.default,
                    handler: nil
                )
            )

            topLevelViewController()?.present(alertVC, animated: true)
        }
    }

    private static func modalPresentingViewController() -> UIViewController? {
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

        guard
            let rootViewController = window?.rootViewController
        else {
            return nil
        }

        var currentViewController: UIViewController? = rootViewController
        while let presentedVC = currentViewController?.presentedViewController {
            currentViewController = presentedVC
        }

        return currentViewController
    }

    private static func topLevelNavController() -> UINavigationController? {
        guard
            let topLevelVC = AlertPresenter.topLevelViewController()
        else {
            return nil
        }

        var topLevelNav: UINavigationController?
        var targetViewController: UIViewController? = topLevelVC

        while targetViewController != nil {
            if let navVC = targetViewController as? UINavigationController {
                topLevelNav = navVC
                targetViewController = nil
            } else if let parentVC = targetViewController?.navigationController {
                targetViewController = parentVC
            } else if let parentVC = targetViewController?.parent {
                targetViewController = parentVC
            } else if let parentVC = targetViewController?.presentingViewController {
                targetViewController = parentVC
            } else if let tabVC = targetViewController as? UITabBarController {
                targetViewController = tabVC.selectedViewController
            } else {
                targetViewController = nil
            }
        }

        return topLevelNav
    }

    private func topLevelParentViewController() -> UIViewController? {
        guard
            let topLevelVC = AlertPresenter.topLevelViewController()
        else {
            return nil
        }

        var parentVC: UIViewController? = topLevelVC.presentingViewController
        if let navVC = parentVC as? UINavigationController {
            parentVC = navVC.topViewController
        }

        return parentVC
    }

    private static func topLevelViewController() -> UIViewController? {
        guard
            let presentingVC = AlertPresenter.modalPresentingViewController()
        else {
            return nil
        }

        var topLevelVC: UIViewController? = presentingVC
        if let navVC = topLevelVC as? UITabBarController {
            topLevelVC = navVC.selectedViewController
        }

        if let navVC = topLevelVC as? UINavigationController {
            topLevelVC = navVC.visibleViewController
        }

        return topLevelVC
    }
}
