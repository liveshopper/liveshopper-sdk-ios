import LiveShopperSDK
import UIKit

class DateView: QuestionView {
    @IBOutlet var datePicker: UIDatePicker!

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm/dd/yy"
        return formatter
    }()

    @IBAction
    func onNext(_: Any) {
        let date = datePicker.date

        submit(
            answers: nil,
            userAnswer: dateFormatter.string(from: date),
            image: image
        )
    }
}
