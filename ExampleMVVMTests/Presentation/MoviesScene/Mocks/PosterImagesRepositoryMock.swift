import Foundation
import XCTest

class PosterImagesRepositoryMock: PosterImagesRepository {
    var completionCalls = 0
    var error: Error?
    var image = Data()
    var validateInput: ((String, Int) -> Void)?
    
    func fetchImage(with imagePath: String, width: Int, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        validateInput?(imagePath, width)
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(image))
        }
        completionCalls += 1
        return nil
    }
}
