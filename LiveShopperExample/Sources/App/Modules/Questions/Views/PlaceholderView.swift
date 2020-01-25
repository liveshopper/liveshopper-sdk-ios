import LiveShopperSDK
import UIKit

class PlaceholderView: QuestionView {
    @IBOutlet var textLabel: UILabel!

    @IBAction
    func onNext(_: Any) {
        // intentionally empty
    }

    override func update(_ question: LSQuestion) {
        super.update(question)

        textLabel.text = String(format: "Question of type '%@' is not\nsupported yet.", (question.type.rawValue))
    }
}
