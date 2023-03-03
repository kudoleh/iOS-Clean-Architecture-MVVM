import Foundation

protocol UseCase {
    @discardableResult
    func start() -> Cancellable?
}
