import NnCredentialKit

final class StubResultStore {
    private let firstResult: AccountCredentialResult
    private let secondResult: AccountCredentialResult
    
    private var shouldReturnFirstResult = true
    
    init(firstResult: AccountCredentialResult, secondResult: AccountCredentialResult) {
        self.firstResult = firstResult
        self.secondResult = secondResult
    }
}


// MARK: - Action
extension StubResultStore {
    func getResult() -> AccountCredentialResult {
        guard shouldReturnFirstResult else {
            return secondResult
        }
        
        shouldReturnFirstResult = false
        
        return firstResult
    }
}
