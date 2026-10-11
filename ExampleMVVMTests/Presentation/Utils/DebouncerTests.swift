import XCTest

final class DebouncerTests: XCTestCase {

    final class DebounceSchedulerTypeMock: DebounceSchedulerType {
        private(set) var scheduledWork: [() -> Void] = []

        func asyncAfter(seconds: TimeInterval, execute work: @escaping () -> Void) {
            scheduledWork.append(work)
        }

        /// Simulates time passing: runs every work item scheduled so far, in order.
        func fireAll() {
            let pending = scheduledWork
            scheduledWork.removeAll()
            pending.forEach { $0() }
        }
    }

    func test_whenExecutedOnce_thenActionDoesNotRunUntilScheduledWorkFires() {
        let scheduler = DebounceSchedulerTypeMock()
        let debouncer = DefaultDebouncer(delay: 0.3, scheduler: scheduler)
        var callCount = 0

        debouncer.execute { callCount += 1 }

        XCTAssertEqual(callCount, 0)
        scheduler.fireAll()
        XCTAssertEqual(callCount, 1)
    }

    func test_whenExecutedRapidlyMultipleTimes_thenOnlyLastActionRuns() {
        let scheduler = DebounceSchedulerTypeMock()
        let debouncer = DefaultDebouncer(delay: 0.3, scheduler: scheduler)
        var results: [Int] = []

        debouncer.execute { results.append(1) }
        debouncer.execute { results.append(2) }
        debouncer.execute { results.append(3) }

        scheduler.fireAll()

        XCTAssertEqual(results, [3])
    }

    func test_whenCancelled_thenPendingActionDoesNotRun() {
        let scheduler = DebounceSchedulerTypeMock()
        let debouncer = DefaultDebouncer(delay: 0.3, scheduler: scheduler)
        var didRun = false

        debouncer.execute { didRun = true }
        debouncer.cancel()
        scheduler.fireAll()

        XCTAssertFalse(didRun)
    }

    func test_whenExecutedAgainAfterPreviousActionAlreadyFired_thenNewActionStillRuns() {
        let scheduler = DebounceSchedulerTypeMock()
        let debouncer = DefaultDebouncer(delay: 0.3, scheduler: scheduler)
        var results: [Int] = []

        debouncer.execute { results.append(1) }
        scheduler.fireAll()

        debouncer.execute { results.append(2) }
        scheduler.fireAll()

        XCTAssertEqual(results, [1, 2])
    }
}
