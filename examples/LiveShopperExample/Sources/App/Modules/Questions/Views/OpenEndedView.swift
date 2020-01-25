import LiveShopperSDK
import UIKit

class OpenEndedView: QuestionView, UITextViewDelegate {
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var rangeLabel: UILabel!
    @IBOutlet var textView: UITextView! {
        didSet {
            textView.layer.borderWidth = 1.0
            textView.layer.borderColor = UIColor.black.cgColor
        }
    }

    @objc
    func beganEditing() {
        placeholderLabel.isHidden = true
    }

    @objc
    func endedEditing() {
        markDirty(values: nil, value: getAnswer())
    }

    @IBAction
    func onNext(_: Any) {
        submit(answers: nil, userAnswer: getAnswer(), image: image)
    }

    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    @objc
    func textChanged() {
        markDirty(values: nil, value: getAnswer())
    }

    override func update(_ question: LSQuestion) {
        super.update(question)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: UITextView.textDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(beganEditing),
            name: UITextView.textDidBeginEditingNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(endedEditing),
            name: UITextView.textDidEndEditingNotification,
            object: nil
        )

        placeholderLabel.text = question.openTextPlaceholder

        if let minValue = question.minValue, let maxValue = question.maxValue {
            rangeLabel.text = "Response must be between \(minValue) and \(maxValue) characters"
        } else {
            rangeLabel.isHidden = true
        }
    }

    private func getAnswer() -> String {
        textView.text ?? ""
    }
}
