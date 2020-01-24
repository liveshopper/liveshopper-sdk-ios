import LiveShopperSDK
import M13Checkbox
import UIKit

class SingleAnswerView: QuestionView, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!

    typealias TableCellClass = SingleChoiceOptionView

    private let reuseIdentifier = "SingleChoiceOptionView"
    private var checkedIndex: Int?

    override func awakeFromNib() {
        super.awakeFromNib()

        let nib = UINib(nibName: reuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }

    @IBAction
    func onNext(_: Any) {
        submit(answers: getAnswers(), userAnswer: nil, image: image)
    }

    override func updateConstraints() {
        super.updateConstraints()

        tableHeightConstraint.constant = tableView.contentSize.height
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return question?.answers.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TableCellClass,
            let answer = question?.answers[indexPath.row]
        else {
            return UITableViewCell()
        }

        cell.textLabel?.text = answer.displayText

        cell.onRadio = { [weak self] in
            guard
                let self = self
            else {
                return
            }

            self.checkedIndex = indexPath.row
            self.tableView.reloadData()
            self.markDirty(values: self.getAnswers(), value: nil)
        }

        if let checkedIndex = checkedIndex, indexPath.row == checkedIndex {
            cell.radioButton.checkState = .checked
        } else {
            cell.radioButton.checkState = .unchecked
        }

        return cell
    }

    private func getAnswers() -> [String] {
        guard
            let index = checkedIndex,
            let answer = question?.answers[index]
        else { return [] }

        return [answer].compactMap { $0.key }
    }
}
