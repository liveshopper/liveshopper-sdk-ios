import UIKit

extension UINavigationController {
    func removeFromNavigationStack(viewController: UIViewController) {
        viewControllers.removeAll(where: { $0 === viewController })
    }
}
