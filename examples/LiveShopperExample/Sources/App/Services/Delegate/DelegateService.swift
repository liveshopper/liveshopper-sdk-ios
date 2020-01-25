protocol SDKDelegate: class {
    var state: SDKState { get set }
}

class DelegateService {
    var delegates = [SDKDelegate]()
}

extension DelegateService: DelegateServiceProtocol {
    func notify(state: SDKState) {
        delegates.forEach {
            $0.state = state
        }
    }

    func register(delegate: SDKDelegate) {
        delegates.append(delegate)
    }
}
