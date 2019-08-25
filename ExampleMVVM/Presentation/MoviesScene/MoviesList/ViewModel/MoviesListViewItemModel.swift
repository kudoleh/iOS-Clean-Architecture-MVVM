//
//  MoviesListViewItemModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 18.02.19.
//

import Foundation

protocol MoviesListViewItemModelInput {
    func viewDidLoad()
    func updatePosterImage(width: Int)
}

protocol MoviesListViewItemModelOutput {
    var title: String { get }
    var overview: String { get }
    var releaseDate: String { get }
    var posterImage: Observable<Data?> { get }
    var posterPath: String? { get }
}

protocol MoviesListViewItemModel: MoviesListViewItemModelInput, MoviesListViewItemModelOutput { }

final class DefaultMoviesListViewItemModel: MoviesListViewItemModel {
    
    private(set) var id: Int

    // MARK: - OUTPUT
    let title: String
    let overview: String
    let releaseDate: String
    private(set) var posterPath: String?
    private(set) var posterImage: Observable<Data?> = Observable(nil)

    private let posterImagesRepository: PosterImagesRepository
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }

    init(movie: Movie,
         posterImagesRepository: PosterImagesRepository) {
        self.id = movie.id
        self.title = movie.title
        self.posterPath = movie.posterPath
        self.overview = movie.overview
        self.releaseDate = movie.releaseDate != nil ? dateFormatter.string(from: movie.releaseDate!) : NSLocalizedString("To be announced", comment: "")
        self.posterImagesRepository = posterImagesRepository
    }
}

// MARK: - INPUT. View event methods
extension DefaultMoviesListViewItemModel {
    
    func viewDidLoad() {}
    
    func updatePosterImage(width: Int) {
        posterImage.value = nil
        guard let posterPath = posterPath else { return }
        
        imageLoadTask = posterImagesRepository.image(with: posterPath, width: width) { [weak self] result in
            guard self?.posterPath == posterPath else { return }
            switch result {
            case .success(let data):
                self?.posterImage.value = data
            case .failure: break
            }
            self?.imageLoadTask = nil
        }
    }
}

func == (lhs: DefaultMoviesListViewItemModel, rhs: DefaultMoviesListViewItemModel) -> Bool {
    return (lhs.id == rhs.id)
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
