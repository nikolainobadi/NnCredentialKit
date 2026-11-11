@testable import NnCredentialKit

extension CredentialType {
    var id: String {
        switch self {
        case .apple:
            return "apple"
        case .google:
            return "google"
        case .emailPassword:
            return "emailPassword"
        }
    }
}
