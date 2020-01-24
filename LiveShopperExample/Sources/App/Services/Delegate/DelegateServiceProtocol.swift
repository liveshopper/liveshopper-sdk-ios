protocol DelegateServiceProtocol {
    func notify(state: SDKState)
    func register(delegate: SDKDelegate)
}
