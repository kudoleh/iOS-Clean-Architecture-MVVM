//
//  MoviesListPageViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 18.02.19.
//

import Foundation

struct MoviesListPageViewModel: Equatable {
    let page: Int
    let movies: [MoviesListPageViewModel.MovieViewModel]
}

extension MoviesListPageViewModel {
    init(moviePage: MoviesPage) {
        self.page = moviePage.page
        self.movies = moviePage.movies.map(MoviesListPageViewModel.MovieViewModel.init)
    }
}

extension MoviesListPageViewModel {

    struct MovieViewModel: Equatable {
        let title: String
        let overview: String
        let releaseDate: String
        let posterImagePath: String?

        init(movie: Movie) {
            self.title = movie.title ?? ""
            self.posterImagePath = movie.posterPath
            self.overview = movie.overview ?? ""
            if let releaseDate = movie.releaseDate {
                self.releaseDate = "\(NSLocalizedString("Release Date", comment: "")): \(dateFormatter.string(from: releaseDate))"
            } else {
                self.releaseDate = NSLocalizedString("To be announced", comment: "")
            }
        }
    }
}


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
