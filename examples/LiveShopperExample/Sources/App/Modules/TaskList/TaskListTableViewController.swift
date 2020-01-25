import LiveShopperSDK
import UIKit

class TaskListTableViewController: UITableViewController {
    private let reuseIdentifier = "taskTableViewCell"
    private var tasks: [LSTask] = []

    var state: SDKState = .loading {
        willSet(newState) {
            update(newState)
        }
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationController = segue.destination as? TaskOverviewViewController, let selectedTask = sender as? LSTask {
            destinationController.task = selectedTask
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return tasks.count
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 70.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TaskTableViewCell
        else {
            return UITableViewCell()
        }

        cell.setup(with: tasks[indexPath.row])

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]

        if task.state == .completed {
            let identifier = "RewardsViewController"
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            guard
                let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? RewardsViewController
            else {
                fatalError("RewardsViewController not found in storyboard")
            }

            viewController.task = task

            present(viewController, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: SegueIdentifier.taskOverview, sender: task)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tasks = App.shared.taskService.tasks
        App.shared.delegateService.register(delegate: self)
    }

    override func viewWillAppear(_: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    private func sortTasks(_ tasks: [LSTask]) -> [LSTask] {
        return tasks.sorted { $0.distance < $1.distance }
    }
}

extension TaskListTableViewController: SDKDelegate {
    func update(_ newState: SDKState) {
        switch (state, newState) {
            case (.loading, .loading): toLoading()
            case (.loading, .loaded), (.loaded, .loaded): toLoaded()
            default: fatalError("Transition from \(state) to \(newState) unsupported.")
        }
    }

    private func toLoaded() {
        let newTasks = App.shared.taskService.tasks
        tasks = sortTasks(newTasks)
    }

    private func toLoading() {}
}
