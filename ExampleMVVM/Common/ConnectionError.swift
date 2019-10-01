//
//  ConnectionError.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.19.
//

import Foundation

public protocol ConnectionError: Error {
    var isInternetConnectionError: Bool { get }
}

public extension Error {
    var isInternetConnectionError: Bool {
        guard let error = self as? ConnectionError, error.isInternetConnectionError else {
            return false
        }
        return true
    }
}
