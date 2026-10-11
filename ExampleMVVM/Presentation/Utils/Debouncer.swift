import Foundation

/// Coalesces rapid, repeated calls (e.g. search-as-you-type) into a single action that runs
/// only after a quiet period, so that a newer call cancels whatever older call hasn't fired yet.
protocol Debouncer {
    func execute(_ action: @escaping () -> Void)
    func cancel()
}

/// Abstracts delayed scheduling so `DefaultDebouncer` can be unit tested without real delays.
protocol DebounceSchedulerType {
    func asyncAfter(seconds: TimeInterval, execute work: @escaping () -> Void)
}

extension DispatchQueue: DebounceSchedulerType {
    func asyncAfter(seconds: TimeInterval, execute work: @escaping () -> Void) {
        asyncAfter(deadline: .now() + seconds, execute: work)
    }
}

final class DefaultDebouncer: Debouncer {

    private let delay: TimeInterval
    private let scheduler: DebounceSchedulerType
    private var currentToken = 0

    init(delay: TimeInterval, scheduler: DebounceSchedulerType = DispatchQueue.main) {
        self.delay = delay
        self.scheduler = scheduler
    }

    func execute(_ action: @escaping () -> Void) {
        currentToken += 1
        let scheduledToken = currentToken

        scheduler.asyncAfter(seconds: delay) { [weak self] in
            guard let self, self.currentToken == scheduledToken else { return }
            action()
        }
    }

    func cancel() {
        currentToken += 1
    }
}
