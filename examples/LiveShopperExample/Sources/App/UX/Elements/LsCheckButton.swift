import M13Checkbox
import UIKit

class LsCheckButton: M13Checkbox {
    override func awakeFromNib() {
        super.awakeFromNib()

        markType = .checkmark
        boxType = .square
        stateChangeAnimation = .fill
        // tintColor = .lightGray
        boxLineWidth = 2
        checkmarkLineWidth = 5
    }
}
