import Foundation

class RepositoryTask: Cancellable {
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
}
