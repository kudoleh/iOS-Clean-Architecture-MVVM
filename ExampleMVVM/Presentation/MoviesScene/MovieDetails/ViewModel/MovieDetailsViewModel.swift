//
//  MovieDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 04.08.19.
//  Copyright (c) 2019 All rights reserved.
//

import Foundation

protocol MovieDetailsViewModelInput {
    func updatePosterImage(width: Int)
}

protocol MovieDetailsViewModelOutput {
    var title: Observable<String> { get }
    var posterImage: Observable<Data?> { get }
    var overview: Observable<String> { get }
}

protocol MovieDetailsViewModel: MovieDetailsViewModelInput, MovieDetailsViewModelOutput { }

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {
    
    private let posterPath: String?
    private let posterImagesRepository: PosterImagesRepository
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    private var alreadyLoadedImageWidth: Int?
    
    // MARK: - OUTPUT
    let title: Observable<String> = Observable("")
    let posterImage: Observable<Data?> = Observable(nil)
    let overview: Observable<String> = Observable("")
    
    init(title: String,
         overview: String,
         posterPlaceholderImage: Data?,
         posterPath: String?,
         posterImagesRepository: PosterImagesRepository) {
        self.title.value = title
        self.overview.value = overview
        self.posterImage.value = posterPlaceholderImage
        self.posterPath = posterPath
        self.posterImagesRepository = posterImagesRepository
    }
}

// MARK: - INPUT. View event methods
extension DefaultMovieDetailsViewModel {
    
    func updatePosterImage(width: Int) {
        guard let posterPath = posterPath, alreadyLoadedImageWidth != width  else { return }
        alreadyLoadedImageWidth = width
        
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
