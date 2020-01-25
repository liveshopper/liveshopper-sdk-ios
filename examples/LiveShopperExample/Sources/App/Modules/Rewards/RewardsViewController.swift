import LiveShopperSDK
import UIKit

class RewardsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    typealias TableCellClass = RewardTableViewCell
    let reuseIdentifier = String(describing: TableCellClass.self)

    var task: LSTask? {
        didSet {
            guard
                tableView != nil
            else {
                return
            }

            tableView.reloadData()
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return task?.rewards.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TableCellClass,
            let task = self.task
        else {
            return UITableViewCell()
        }

        let reward = task.rewards[indexPath.row]

        cell.configure(with: reward)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let task = self.task,
            let reward = self.task?.rewards[indexPath.row]
        else {
            return
        }

        LiveShopper.Rewards.claim(task: task, reward: reward) { result in
            if case .success = result {
                AlertPresenter.presentAlert(type: .rewardClaimed)
            } else if case let .failure(error) = result {
                AlertPresenter.presentAlert(type: .apiError(error))
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func cancelTapped(_: Any) {
        let parentViewController = presentingViewController
        let navigationController: UINavigationController?

        if
            let rootVC = parentViewController as? ViewController,
            let tabVC = rootVC.children.compactMap({ $0 as? UITabBarController }).first {
            navigationController = tabVC.selectedViewController as? UINavigationController
        } else {
            navigationController = nil
        }

        navigationController?.popViewController(animated: false)

        dismiss(
            animated: true,
            completion: {
                navigationController?.popToRootViewController(animated: true)
            }
        )
    }

    static func create() -> RewardsViewController {
        let identifier = "RewardsViewController"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard
            let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? RewardsViewController
        else {
            fatalError("\(identifier) not found in storyboard")
        }

        return viewController
    }
}
