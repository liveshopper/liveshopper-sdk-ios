import M13Checkbox
import UIKit

class LsRadioButton: M13Checkbox {
    override func awakeFromNib() {
        super.awakeFromNib()

        markType = .radio
        boxType = .circle
        stateChangeAnimation = .fill
        // tintColor = .lightGray
        boxLineWidth = 2
        checkmarkLineWidth = 5
    }
}
