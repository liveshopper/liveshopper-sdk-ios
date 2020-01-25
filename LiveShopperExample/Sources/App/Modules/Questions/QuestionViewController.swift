import LiveShopperSDK
import MobileCoreServices
import UIKit

// swiftlint:disable cyclomatic_complexity
class QuestionViewController: UIViewController {
    @IBOutlet var loadingView: UIView!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!

    private var questionHandler: QuestionHandler?

    private var questionView: QuestionView? {
        didSet {
            questionView?.photoDelegate = self
            questionView?.questionSubmitDelegate = self
        }
    }

    var state: UIState = .loading {
        willSet(newState) {
            update(newState)
        }
    }

    func configure(handler: QuestionHandler) {
        questionHandler = handler
    }

    @objc
    func tapped() {
        _ = questionView?.resignFirstResponder()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        guard let view = questionView else { return }

        scrollView.contentSize = view.bounds.size
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let view = questionView else { return }

        scrollView.contentSize = view.bounds.size
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let questionHandler = self.questionHandler else { return }

        if let previousView = questionView {
            previousView.removeFromSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tapGesture)

        questionHandler.delegate = self
        questionHandler.load()
    }

    static func create() -> QuestionViewController {
        let identifier = "QuestionViewController"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard
            let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? QuestionViewController
        else {
            fatalError("QuestionViewController not found in storyboard")
        }

        return viewController
    }
}

extension QuestionViewController: BarcodeScannerDelegate {
    func scanningDidFail() {}
    func scanningDidStop() {}
    func scanningSucceeded(code: String?) {
        (questionView as? BarcodeView)?.setBarcode(code: code)
    }
}

extension QuestionViewController: BarcodeViewDelegate {
    func scanBarcodePressed() {
        guard let handler = self.questionHandler else { return }

        handler.displayBarcodeScanner()
    }
}

extension QuestionViewController: PhotoViewDelegate {
    func takePhotoPressed() {
        guard let handler = self.questionHandler else { return }

        handler.displayImagePicker()
    }
}

extension QuestionViewController: QuestionDelegate {
    func update(_ newState: UIState) {
        switch (state, newState) {
            case (.loading, .loading): toLoading()
            case let (.loading, .loaded(task, question)): toLoaded(task: task, question: question)
            case let (.loaded, .questionModified(question, values, value)): toQuestionModified(question: question, values: values, value: value)
            case let (.openedBarcodeScanner, .questionModified(question, values, value)): toQuestionModified(question: question, values: values, value: value)
            case let (.openedImagePicker, .questionModified(question, values, value)): toQuestionModified(question: question, values: values, value: value)
            case (.loaded, .openedBarcodeScanner): toOpenedBarcodeScanner()
            case (.questionModified, .openedBarcodeScanner): toOpenedBarcodeScanner()
            case let (.loaded, .openedImagePicker(question)): toOpenedImagePicker(question: question)
            case let (.questionModified, .openedImagePicker(question)): toOpenedImagePicker(question: question)
            case (.questionModified, .submitStarted): toSubmitStarted()
            case (.submitStarted, .submitSuccess): toSubmitSuccess()
            case let (.submitStarted, .submitFailed(error)): toSubmitFailed(error: error)
            case (.submitSuccess, .loading): toLoading()
            case let (.submitFailed, .questionModified(question, values, value)): toQuestionModified(question: question, values: values, value: value)
            case let (.submitSuccess, .taskComplete(task)): toTaskComplete(task: task)
            case let (.loading, .taskComplete(task)): toTaskComplete(task: task)
            default: fatalError("Transition from \(state) to \(newState) unsupported.")
        }
    }

    private func getView(for question: LSQuestion) -> QuestionView {
        switch question.type {
            case .barcodeScan:
                let view: BarcodeView = UIView.fromNib(name: "BarcodeView")
                view.delegate = self
                return view
            case .date:
                let view: DateView = UIView.fromNib(name: "DateView")
                return view
            case .multipleAnswers:
                let view: MultipleChoiceView = UIView.fromNib(name: "MultipleChoiceView")
                return view
            case .numericOpenEnded:
                let view: NumericView = UIView.fromNib(name: "NumericView")
                return view
            case .openEnded:
                let view: OpenEndedView = UIView.fromNib(name: "OpenEndedView")
                return view
            case .ratingScale, .ratingScaleWithText:
                let view: RatingScaleView = UIView.fromNib(name: "RatingScaleView")
                return view
            case .singleAnswer:
                let view: SingleAnswerView = UIView.fromNib(name: "SingleAnswerView")
                return view
            case .time:
                let view: TimeView = UIView.fromNib(name: "TimeView")
                return view
            default:
                let view: PlaceholderView = UIView.fromNib(name: "PlaceholderView")
                return view
        }
    }

    func presentRewardScreen(task: LSTask) {
        let viewController = RewardsViewController.create()
        viewController.task = task

        navigationController?.pushViewController(viewController, animated: true)
        navigationController?.removeFromNavigationStack(viewController: self)
    }

    private func toLoaded(task: LSTask, question: LSQuestion) {
        loadingView.isHidden = true

        title = task.title

        if let previousView = questionView {
            previousView.removeFromSuperview()
        }

        let questionIndex = question.order ?? 0
        questionLabel.text = "Question \(questionIndex + 1) of \(task.questions.count)"

        questionView = getView(for: question)

        if questionView != nil {
            questionView?.update(question)

            scrollView.addSubview(questionView!)
            scrollView.contentSize = questionView!.bounds.size
            scrollView.contentOffset.y = 0
        }

        view.setNeedsUpdateConstraints()
        view.setNeedsLayout()
    }

    private func toLoading() {
        loadingView.isHidden = false
    }

    private func toOpenedBarcodeScanner() {
        let scanner = LiveShopper.createBarcodeScanner()

        scanner.delegate = self
        present(scanner, animated: true)
    }

    private func toOpenedImagePicker(question: LSQuestion) {
        guard let picker = LiveShopper.createImagePicker(question: question) else { return }

        picker.delegate = self
        present(picker, animated: true)
    }

    private func toQuestionModified(question: LSQuestion, values: [String]? = nil, value: String? = nil) {
        guard
            let questionView = self.questionView,
            let photoOptions = question.photoCaptureOptions
        else { return }

        let photoIsRequired = !(photoOptions.mustProvidePhoto && questionView.image == nil)

        var enableNext: Bool = false
        switch question.type {
            case .barcodeScan, .numericOpenEnded, .openEnded:
                enableNext = photoIsRequired && value != nil && value != ""
            case .multipleAnswers:
                enableNext = photoIsRequired && values != nil && values!.count > 0
            case .singleAnswer:
                enableNext = photoIsRequired && values != nil && values!.count == 1
            default:
                enableNext = photoIsRequired
        }

        questionView.nextButton.isEnabled = enableNext
    }

    private func toSubmitFailed(error: LiveShopperError) {
        loadingView.isHidden = true
        AlertPresenter.presentAlert(type: .genericNetworkError(error.message))
    }

    private func toSubmitStarted() {
        loadingView.isHidden = false
    }

    private func toSubmitSuccess() {
        loadingView.isHidden = true
    }

    private func toTaskComplete(task: LSTask) {
        presentRewardScreen(task: task)
    }
}

extension QuestionViewController: QuestionSubmitDelegate {
    func ready(values: [String]? = nil, value: String? = nil) {
        guard let handler = self.questionHandler else { return }
        handler.markDirty(values: values, value: value)
    }

    func submit(answers: [String]?, userAnswer: String?, image: UIImage?) {
        guard let handler = self.questionHandler else { return }

        handler.submit(answers: answers, userAnswer: userAnswer, image: image)
    }
}

extension QuestionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            questionView?.image = image
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension QuestionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_: UIScrollView) {
        _ = questionView?.resignFirstResponder()
    }
}
