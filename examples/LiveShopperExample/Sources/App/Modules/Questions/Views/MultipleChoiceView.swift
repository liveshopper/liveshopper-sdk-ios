import LiveShopperSDK
import M13Checkbox
import UIKit

class MultipleChoiceView: QuestionView, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var limitationLabel: UILabel!
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.allowsSelection = false
        }
    }

    typealias TableCellClass = MultipleChoiceOptionView
    private let reuseIdentifier = "MultipleChoiceOptionView"
    private var checkMap = [Int: Bool]()

    override func awakeFromNib() {
        super.awakeFromNib()

        let nib = UINib(nibName: reuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }

    @IBAction
    func onNext(_: Any) {
        submit(
            answers: getAnswers(),
            userAnswer: nil,
            image: image
        )
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return question?.answers.count ?? 0
    }

    func tableView(_: UITableView, shouldHighlightRowAt _: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TableCellClass,
            let answer = question?.answers[indexPath.row]
        else {
            return UITableViewCell()
        }

        cell.textLabel?.text = answer.displayText
        cell.checkButton.checkState = checkMap[indexPath.row] == true ? .checked : .unchecked

        cell.onCheckbox = { [weak self] checked in
            guard let self = self else { return }

            self.checkMap[indexPath.row] = checked
            self.markDirty(values: self.getAnswers(), value: nil)
        }

        return cell
    }

    override func update(_ question: LSQuestion) {
        super.update(question)

        questionLabel.text = question.question

        if let minAnswers = question.minMultipleAnswers, let maxAnswers = question.maxMultipleAnswers {
            limitationLabel.text = "Please select between \(minAnswers) and \(maxAnswers) response(s)"
        } else {
            limitationLabel.isHidden = true
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        tableHeightConstraint.constant = tableView.contentSize.height
    }

    private func getAnswers() -> [String]? {
        let answers = checkMap.filter { $1 }.keys.compactMap { index in question.answers[index] }

        return answers.compactMap { $0.key }
    }
}
