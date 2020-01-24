import UIKit

class LsButton: UIButton {
    override var isEnabled: Bool {
        willSet {
            backgroundColor = newValue ? .blue : .lightGray
        }
    }
}
