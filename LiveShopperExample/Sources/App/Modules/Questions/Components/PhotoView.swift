import LiveShopperSDK
import UIKit

protocol PhotoViewDelegate: class {
    func takePhotoPressed()
}

class PhotoView: UIView {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var photoImageView: UIImageView!

    weak var delegate: PhotoViewDelegate?

    @IBAction
    func photoPressed(_: Any) {
        delegate?.takePhotoPressed()
    }

    func setup(photoCaptureOptions: LSPhotoCaptureOptions) {
        headerLabel.text = photoCaptureOptions.photoPromptText
    }
}
