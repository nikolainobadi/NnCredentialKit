/// Internal helper for printing debug messages to the console.
enum CredentialKitLogger {
    /// Prints a message to the console when debug logging is enabled.
    ///
    /// - Parameters:
    ///   - message: The message to print.
    ///   - isEnabled: When `false`, nothing is printed.
    static func log(_ message: String, isEnabled: Bool) {
        if isEnabled {
            print("[NnCredentialKit] \(message)")
        }
    }
}
