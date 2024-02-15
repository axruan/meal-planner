//
//  Extensions.swift
//
//
///Convenient extensions
///
import Foundation
import SwiftUI

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
}

extension Data {
    func printJSON() {
        if let JSONString = String(data: self, encoding: .utf8) {
            print(JSONString)
        }
    }
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}

extension String {
    var capitalizedSentence: String {
        // 1
        let firstLetter = self.prefix(1).capitalized
        // 2
        let remainingLetters = self.dropFirst().lowercased()
        // 3
        return firstLetter + remainingLetters
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
