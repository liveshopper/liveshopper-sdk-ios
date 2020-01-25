import CoreLocation
import LiveShopperSDK
import M13Checkbox
import UIKit

// swiftlint:disable force_cast
class ChecklistViewController: UIViewController {
    @IBOutlet var checkboxesView: UIView!
    @IBOutlet var checkboxViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var claimTaskButton: LsButton!
    @IBOutlet var loadingView: UIView!

    var task: LSTask?

    private var checkBoxViews = [M13Checkbox]()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let task = sender, let destinationController = segue.destination as? QuestionViewController {
            let controller = QuestionController(task: task as! LSTask)
            destinationController.configure(handler: controller)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = task?.title
        navigationItem.backBarButtonItem?.title = "Cancel"

        setup()
    }

    @IBAction
    func claimTask(_: Any) {
        loadingView.isHidden = false

        guard let task = task else { return }

        LiveShopper.Tasks.claim(task: task) { [weak self] result in
            guard let self = self else { return }

            if case let .success(claimedTask) = result {
                let viewController = QuestionViewController.create()
                viewController.configure(handler: self.createController(claimedTask))

                self.navigationController?.pushViewController(viewController, animated: true)
                self.navigationController?.removeFromNavigationStack(viewController: self)
            } else if case let .failure(error) = result {
                AlertPresenter.presentAlert(type: .apiError(error))
            }

            self.loadingView.isHidden = true
        }
    }

    func setup() {
        var nextY: CGFloat = 0
        let width = checkboxesView.bounds.width

        guard let task = task else { return }

        let fullRequirements = LiveShopper.Tasks.getRequirements(task: task)

        for item in fullRequirements {
            let view = UIView()
            view.frame = CGRect(x: 0, y: nextY, width: width, height: 40)

            let check = M13Checkbox(frame: CGRect(x: 0, y: 5, width: 20, height: 20))

            view.addSubview(check)
            check.boxType = .square
            check.addTarget(self, action: #selector(updateClaimButtonState), for: .valueChanged)
            checkBoxViews.append(check)

            let nextX = (check.bounds.width + 20)
            let labelWidth = view.bounds.width - nextX
            let label = UILabel(frame: CGRect(x: check.bounds.width + 20, y: 5, width: labelWidth, height: 100))
            label.text = item
            label.textColor = UIColor.lightGray
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.sizeToFit()
            view.addSubview(label)

            checkboxesView.addSubview(view)
            let newHeight = max(label.bounds.height, 40)
            view.frame = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.width, height: newHeight))

            nextY += view.bounds.height + 10
        }

        let newHeight = checkboxesView.frame.origin.y + nextY
        checkboxViewHeightConstraint.constant = newHeight

        updateClaimButtonState()
    }

    private func createController(_ task: LSTask) -> QuestionController {
        let controller = QuestionController(task: task)

        return controller
    }

    @objc
    private func updateClaimButtonState() {
        let enableButton = checkBoxViews.count == checkBoxViews.filter { $0.checkState == .checked }.count

        claimTaskButton.isEnabled = enableButton

        if enableButton {
            claimTaskButton.alpha = 1.0
        } else {
            claimTaskButton.alpha = 0.5
        }
    }
}
