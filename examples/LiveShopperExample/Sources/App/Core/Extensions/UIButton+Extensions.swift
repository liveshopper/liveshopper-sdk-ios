import UIKit

extension UIButton {
    // update the buttons color if its disabled
    open override var isEnabled: Bool {
        willSet {
            // backgroundColor = newValue ? .blue : .lightGray
        }
    }
}
