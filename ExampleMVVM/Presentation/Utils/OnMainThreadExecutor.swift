import Foundation

protocol OnMainThreadExecutor {
    func execute(block: @escaping () -> Void)
}

final class DefaultOnMainThreadExecutor: OnMainThreadExecutor {
    let mainQueue: DispatchQueue = .main
    func execute(block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            mainQueue.async {
                block()
            }
        }
    }
}
