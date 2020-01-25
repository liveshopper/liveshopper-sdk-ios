import UIKit

// swiftlint:disable force_cast
extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }

    class func fromNib<T: UIView>(name: String) -> T {
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)![0] as! T
    }
}
