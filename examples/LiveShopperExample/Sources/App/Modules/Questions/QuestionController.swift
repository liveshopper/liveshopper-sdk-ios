import Foundation
import LiveShopperSDK
import UIKit

enum UIState {
    case loading
    case loaded(LSTask, LSQuestion)
    case questionModified(LSQuestion, [String]?, String?)
    case openedBarcodeScanner
    case openedImagePicker(LSQuestion)
    case submitStarted
    case submitSuccess
    case submitFailed(LiveShopperError)
    case taskComplete(LSTask)
}

protocol QuestionDelegate: class {
    var state: UIState { get set }
}

protocol QuestionHandler: class {
    var activeQuestion: LSQuestion? { get set }
    var delegate: QuestionDelegate? { get set }
    var task: LSTask { get set }

    func displayBarcodeScanner()
    func displayImagePicker()
    func load()
    func markDirty(values: [String]?, value: String?)
    func submit(answers: [String]?, userAnswer: String?, image: UIImage?)
}

// swiftlint:disable cyclomatic_complexity function_body_length
class QuestionController: QuestionHandler {
    var activeQuestion: LSQuestion?
    var task: LSTask

    weak var delegate: QuestionDelegate?

    init(task: LSTask) {
        self.task = task
    }

    public func displayImagePicker() {
        guard let question = self.activeQuestion else { return }
        delegate!.state = .openedImagePicker(question)
    }

    public func displayBarcodeScanner() {
        guard let question = self.activeQuestion else { return }

        if question.type == .barcodeScan {
            delegate!.state = .openedBarcodeScanner
        }
    }

    public func load() {
        getFirstQuestion()
    }

    public func markDirty(values: [String]? = nil, value: String? = nil) {
        guard
            let question = self.activeQuestion,
            let delegate = self.delegate
        else { return }

        delegate.state = .questionModified(question, values, value)
    }

    public func submit(
        answers: [String]? = nil,
        userAnswer: String? = nil,
        image: UIImage? = nil
    ) {
        guard
            let question = self.activeQuestion,
            let delegate = self.delegate
        else { return }

        delegate.state = .submitStarted

        let validation = validate(question, answers: answers, userAnswer: userAnswer, image: image)

        if validation.isValid {
            LiveShopper.Tasks.saveResponse(
                task: task,
                question: question,
                answers: answers,
                userAnswer: userAnswer,
                image: image
            ) { result in
                if case let .success(response) = result {
                    self.delegate!.state = .submitSuccess

                    switch response.state {
                        case .completed:
                            self.task.state = .completed
                            self.delegate!.state = .taskComplete(self.task)
                        case .continue:
                            let nextQuestionKey = response.nextKey
                            self.activeQuestion = self.getNextQuestion(key: nextQuestionKey!)
                            delegate.state = .loaded(self.task, self.activeQuestion!)
                        case .error, .invalid:
                            delegate.state = .submitFailed(.questionSubmitError(submitError: .unknown))
                        default:
                            fatalError("A task response was received with an invalid state \(response.state)")
                    }
                } else if case let .failure(error) = result {
                    delegate.state = .submitFailed(error)

                    guard let question = self.activeQuestion else { return }

                    delegate.state = .questionModified(question, answers, userAnswer)
                }
            }
        } else {
            guard let newState = validation.failState else { return }
            delegate.state = newState
        }
    }

    private func getFirstQuestion() {
        guard let key = task.nextQuestion else { return }

        activeQuestion = LiveShopper.Tasks.nextQuestion(task: task, key: key)

        if activeQuestion != nil {
            delegate!.state = .loaded(task, activeQuestion!)
        } else {
            delegate!.state = .taskComplete(task)
        }
    }

    private func getNextQuestion(key: String) -> LSQuestion? {
        return LiveShopper.Tasks.nextQuestion(task: task, key: key)
    }

    private func validate(
        _ question: LSQuestion,
        answers: [String]?,
        userAnswer: String?,
        image: UIImage?
    ) -> (isValid: Bool, failState: UIState?) {
        var isValid: Bool = true
        var failState: UIState?

        switch question.type {
            case .barcodeScan:
                if userAnswer == nil {
                    isValid = false
                    failState = .submitFailed(.questionSubmitError(submitError: .missingBarcode))
                }
            case .date:
                if userAnswer == nil {
                    isValid = false
                    failState = .submitFailed(.questionSubmitError(submitError: .missingDate))
                }
            case .multipleAnswers:
                let min = question.minMultipleAnswers ?? 0
                let max = question.maxMultipleAnswers ?? Int.max

                if answers == nil, answers!.count > max, answers!.count < min {
                    isValid = false
                    failState = .submitFailed(.questionSubmitError(submitError: .answerCountOutOfRange(min, max)))
                }

            case .numericOpenEnded:
                let min = question.minValue ?? 0
                let max = question.maxValue ?? Int.max
                let numericValue = userAnswer ?? ""

                if question.allowDecimals, let doubleValue = Double(numericValue) {
                    if doubleValue < Double(min), doubleValue > Double(max) {
                        isValid = false
                        failState = .submitFailed(.questionSubmitError(submitError: .numberOutOfRange(min, max)))
                    }
                } else if let intValue = Int(numericValue) {
                    if intValue < min, intValue > max {
                        isValid = false
                        failState = .submitFailed(.questionSubmitError(submitError: .numberOutOfRange(min, max)))
                    }
                } else {
                    isValid = false
                    failState = .submitFailed(.questionSubmitError(submitError: .invalidNumberFormat))
                }
            case .openEnded:
                let min = question.minValue ?? 0
                let max = question.maxValue ?? Int.max
                let length = userAnswer?.count ?? 0

                if length < min, length > max {
                    isValid = false
                    failState = .submitFailed(.questionSubmitError(submitError: .charactersOutOfRange(min, max)))
                }
            case .ratingScale, .ratingScaleWithText:
                if userAnswer == nil {
                    isValid = false
                    failState = .submitFailed(.questionSubmitError(submitError: .missingRating))
                }
            case .singleAnswer:
                if answers == nil, answers!.count <= 0 {
                    isValid = false
                    failState = .submitFailed(.questionSubmitError(submitError: .invalidValue))
                }
            case .time:
                if userAnswer == nil {
                    isValid = false
                    failState = .submitFailed(.questionSubmitError(submitError: .missingTime))
                }
            default:
                isValid = true
                failState = nil
        }

        if isValid == true, question.photoCaptureOptions?.mustProvidePhoto == true, image == nil {
            isValid = false
            failState = .submitFailed(.questionSubmitError(submitError: .missingPhoto))
        }

        return (isValid, failState)
    }
}
