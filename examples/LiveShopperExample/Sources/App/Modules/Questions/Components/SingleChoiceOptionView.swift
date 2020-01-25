import UIKit

class SingleChoiceOptionView: UITableViewCell {
    @IBOutlet var radioButton: LsRadioButton!

    var onRadio: (() -> Void)?

    @IBAction
    func radioTapped(_: Any) {
        onRadio?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        textLabel?.text = nil
        onRadio = nil
    }
}
