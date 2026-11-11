import UIKit

/// Extension for UIApplication to provide additional utility methods.
internal extension UIApplication {
    /// Retrieves the top-most view controller in the current window hierarchy.
    /// - Returns: The top-most `UIViewController` if available.
    func getTopViewController() -> UIViewController? {
        var topController = connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?
            .windows
            .filter { $0.isKeyWindow }
            .first?
            .rootViewController
        
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
}
