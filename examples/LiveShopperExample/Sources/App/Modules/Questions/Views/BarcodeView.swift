import LiveShopperSDK
import UIKit

protocol BarcodeViewDelegate: class {
    func scanBarcodePressed()
}

class BarcodeView: QuestionView {
    @IBOutlet var barcodeTextField: UITextField!
    @IBOutlet var scanBarcodeButton: LsButton!
    @IBOutlet var barcodeImageView: UIImageView!

    weak var delegate: BarcodeViewDelegate?

    @IBAction
    func onNext(_: Any) {
        guard let barcode = barcodeTextField.text else { return }

        submit(answers: nil, userAnswer: String(barcode))
    }

    @IBAction
    func scanBarcodePressed(_: Any) {
        delegate?.scanBarcodePressed()
    }

    func setBarcode(code: String?) {
        barcodeTextField.text = code
        markDirty(values: nil, value: barcodeTextField.text)
    }
}
