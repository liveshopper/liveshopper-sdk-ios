import LiveShopperSDK
import UIKit

// swiftlint:disable force_cast
class TaskOverviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var acceptTaskButton: UIButton!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var associateViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var claimableRewardsLabel: UILabel!
    @IBOutlet var claimableRewardsTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var claimableRewardsTableView: UITableView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var locationNameLabel: UILabel!
    @IBOutlet var questionsTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var questionsTableView: UITableView!
    @IBOutlet var taskTitleLabel: UILabel!

    public var task: LSTask? {
        didSet {
            onSet(task: task)
        }
    }

    let kRewardsCellIdentifier = "ClaimableRewardsCell"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationController = segue.destination as? ChecklistViewController {
            destinationController.task = sender as? LSTask
        } else if let questionViewController = segue.destination as? QuestionViewController {
            let controller = QuestionController(task: sender as! LSTask)
            questionViewController.configure(handler: controller)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        claimableRewardsTableHeightConstraint.constant = claimableRewardsTableView.contentSize.height
        questionsTableHeightConstraint.constant = questionsTableView.contentSize.height
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = true

        onSet(task: task)

        claimableRewardsTableView.addTableHeaderViewLine()
        questionsTableView.addTableHeaderViewLine()
    }

    @IBAction
    func acceptTaskTapped(_: Any) {
        guard let task = self.task else { return }

        if task.state == LSTask.State.running {
            performSegue(withIdentifier: "ToQuestions", sender: task)
        } else {
            performSegue(withIdentifier: "ToTaskChecklist", sender: task)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard
            let task = task else {
            return 0
        }

        if tableView == claimableRewardsTableView {
            return task.rewards.count
        } else {
            return task.questions.count
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let task = task
        else {
            return UITableViewCell()
        }

        if
            tableView == claimableRewardsTableView,
            let cell = tableView.dequeueReusableCell(withIdentifier: kRewardsCellIdentifier) {
            let reward = task.rewards[indexPath.row]
            cell.textLabel?.text = reward.message?.header
            cell.detailTextLabel?.text = reward.message?.body

            return cell
        } else {
            let cell = UITableViewCell()
            let question = task.questions[indexPath.row]
            cell.textLabel?.text = question.question

            return cell
        }
    }

    private func onSet(task: LSTask?) {
        guard isViewLoaded else { return }

        addressLabel.text = String(
            format: "%@, %@, %@ %@",
            task?.location.address1 ?? "",
            task?.location.city ?? "",
            task?.location.state ?? "",
            task?.location.zipCode ?? ""
        )

        descriptionLabel.text = task?.description
        distanceLabel.text = task?.distance(metric: false)
        locationNameLabel.text = task?.location.name
        taskTitleLabel.text = task?.title

        if task?.associatesOnly == false {
            associateViewHeightConstraint.constant = 0
        }

        let rewardsCount = task?.rewards.count ?? 0
        claimableRewardsLabel.text = "\(rewardsCount) claimable rewards"

        let buttonTitle = task?.state == .running ? "Resume Task" : "Accept Task"
        acceptTaskButton.setTitle(buttonTitle, for: .normal)
    }
}

extension UIStoryboard {
    func taskOverviewViewController(task: LSTask) -> TaskOverviewViewController? {
        if let controller = instantiateViewController(withIdentifier: "TaskOverviewViewController") as? TaskOverviewViewController {
            controller.task = task
            return controller
        } else {
            fatalError("TaskOverviewViewController could not be found in storyboard!")
        }
    }
}
