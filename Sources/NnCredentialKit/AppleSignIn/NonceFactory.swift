//
//  NonceFactory.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import CryptoKit
import AuthenticationServices

/// A utility class for generating and hashing nonces used in authentication processes.
enum NonceFactory {
    /// Hashes the given input string using SHA-256.
    /// - Parameter input: The input string to hash.
    /// - Returns: The hashed string.
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    /// Generates a random nonce string of the specified length.
    /// - Parameter length: The length of the nonce string. Default is 32.
    /// - Returns: A random nonce string.
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}
