//
//  RepositoryTask.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 25.10.19.
//

import Foundation

struct RepositoryTask: Cancellable {
    let networkTask: NetworkCancellable?
    func cancel() {
        networkTask?.cancel()
    }
}
