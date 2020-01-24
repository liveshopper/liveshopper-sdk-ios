import LiveShopperSDK
import UIKit

class RewardTableViewCell: UITableViewCell {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        headerLabel.text = nil
        messageLabel.text = nil
    }

    func configure(with reward: LSReward) {
        headerLabel.text = reward.message?.header
        messageLabel.text = reward.message?.body
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
