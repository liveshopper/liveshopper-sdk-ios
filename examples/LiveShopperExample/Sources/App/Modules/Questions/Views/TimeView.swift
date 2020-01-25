import LiveShopperSDK
import UIKit

class TimeView: QuestionView {
    @IBOutlet var datePicker: UIDatePicker!

    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = [.day, .hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1

        return formatter
    }()

    @IBAction
    func onNext(_: Any) {
        let time = datePicker.countDownDuration
        let timeString = timeFormatter.string(from: time)

        submit(
            answers: nil,
            userAnswer: timeString,
            image: image
        )
    }
}
