import LiveShopperSDK
import UIKit

class NumericView: QuestionView, UITextFieldDelegate {
    @IBOutlet var numberRangeLabel: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var unitLabel: UILabel!

    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

    @IBAction
    func onNext(_: Any) {
        submit(answers: nil, userAnswer: getAnswer(), image: image)
    }

    override func update(_ question: LSQuestion) {
        super.update(question)

        nextButton.isEnabled = false

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: UITextField.textDidChangeNotification,
            object: nil
        )

        textField.keyboardType = question.allowDecimals == true ? .decimalPad : .numberPad

        unitLabel.text = question.unitOfMeasurementLabel
        textField.becomeFirstResponder()

        if let minValue = question.minValue, let maxValue = question.maxValue {
            numberRangeLabel.text = "Enter a value between \(minValue) and \(maxValue)"
        } else {
            numberRangeLabel.isHidden = true
        }
    }

    @objc
    func textChanged() {
        markDirty(values: nil, value: getAnswer())
    }

    private func getAnswer() -> String {
        textField.text ?? ""
    }
}
