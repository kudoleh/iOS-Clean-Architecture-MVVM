import Foundation

extension DataTransferError: ConnectionError {
    var isInternetConnectionError: Bool {
        guard case let DataTransferError.networkFailure(networkError) = self,
            case .notConnected = networkError else {
                return false
        }
        return true
    }
}
