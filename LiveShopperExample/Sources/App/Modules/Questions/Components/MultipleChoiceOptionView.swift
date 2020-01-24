import UIKit

class MultipleChoiceOptionView: UITableViewCell {
    @IBOutlet var checkButton: LsCheckButton!

    var onCheckbox: ((Bool) -> Void)?

    @IBAction
    func checkboxTapped(_ sender: LsCheckButton) {
        let checked = sender.checkState == .checked
        onCheckbox?(checked)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        textLabel?.text = nil
        onCheckbox = nil
    }
}
