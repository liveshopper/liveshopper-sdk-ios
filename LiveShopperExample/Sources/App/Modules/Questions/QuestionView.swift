import LiveShopperSDK
import UIKit

protocol QuestionSubmitDelegate: class {
    func ready(values: [String]?, value: String?)
    func submit(answers: [String]?, userAnswer: String?, image: UIImage?)
}

class QuestionView: UIView, PhotoViewDelegate {
    @IBOutlet var nextButton: LsButton!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var photoContainerView: UIView? {
        didSet {
            photoContainerView?.addSubview(photoView)

            photoContainerView?.heightAnchor.constraint(
                equalTo: photoView.heightAnchor,
                multiplier: 1.0,
                constant: 0
            ).isActive = true

            photoContainerView?.widthAnchor.constraint(
                equalTo: photoView.widthAnchor,
                multiplier: 1.0,
                constant: 0
            ).isActive = true

            photoView.delegate = self
        }
    }

    private let photoView: PhotoView = UIView.fromNib(name: "PhotoView")

    weak var photoDelegate: PhotoViewDelegate?
    weak var questionSubmitDelegate: QuestionSubmitDelegate?

    var image: UIImage? {
        didSet {
            photoView.photoImageView.image = image
            markDirty()
        }
    }

    var question: LSQuestion!

    func takePhotoPressed() {
        photoDelegate?.takePhotoPressed()
    }

    func markDirty(values: [String]? = nil, value: String? = nil) {
        guard let delegate = self.questionSubmitDelegate else { return }

        delegate.ready(values: values, value: value)
    }

    func submit(
        answers: [String]? = nil,
        userAnswer: String? = nil,
        image: UIImage? = nil
    ) {
        guard let delegate = self.questionSubmitDelegate else { return }

        delegate.submit(answers: answers, userAnswer: userAnswer, image: image)
    }

    func update(_ question: LSQuestion) {
        self.question = question

        questionLabel.text = question.question
        nextButton.isEnabled = false

        if let photoOptions = question.photoCaptureOptions, photoOptions.mustProvidePhoto {
            photoView.setup(photoCaptureOptions: photoOptions)
        } else {
            photoContainerView?.isHidden = true
        }
    }
}
