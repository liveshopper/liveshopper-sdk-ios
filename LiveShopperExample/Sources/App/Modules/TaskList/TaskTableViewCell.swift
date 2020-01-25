import LiveShopperSDK
import UIKit

class TaskTableViewCell: UITableViewCell {
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var rewardLabel: UILabel!
    @IBOutlet var taskImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(with task: LSTask) {
        distanceLabel.text = "\(roundToPlaces(value: task.distance, places: 2))  miles away"
        nameLabel.text = task.location.name
        rewardLabel.text = getFirstRewardText(rewards: task.rewards)
        titleLabel.text = task.title
    }

    private func roundToPlaces(value: Double, places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
    }

    private func getFirstRewardText(rewards: [LSReward]?) -> String {
        guard
            let reward = rewards?[0],
            let message = reward.message
        else {
            return ""
        }

        return message.body ?? ""
    }
}
