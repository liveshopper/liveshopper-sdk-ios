import Cosmos
import LiveShopperSDK
import UIKit

class RatingScaleView: QuestionView {
    @IBOutlet var badRatingLabel: UILabel!
    @IBOutlet var goodRatingLabel: UILabel!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var statementLabel: UILabel!

    @IBAction
    func onNext(_: Any) {
        let rating = getRating()

        submit(answers: nil, userAnswer: String(rating), image: image)
    }

    override func update(_ question: LSQuestion) {
        super.update(question)

        badRatingLabel.text = question.lowValueLabel
        goodRatingLabel.text = question.highValueLabel
        statementLabel.text = question.sentimentText
    }

    private func getRating() -> Int {
        return Int(ratingView.rating)
    }
}
