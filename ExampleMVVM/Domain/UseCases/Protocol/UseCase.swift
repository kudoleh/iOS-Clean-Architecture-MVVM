//
//  UseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01/03/2020.
//

import Foundation

public protocol UseCase {
    @discardableResult
    func start() -> Cancellable?
}
