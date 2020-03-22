//
//  MoviesPage+Decodable.swift
//  Data
//
//  Created by Oleh Kudinov on 12.08.19.
//  Copyright © 2019 Oleh Kudinov. All rights reserved.
//

import Foundation

// MARK: - Data Transfer Object

struct MoviesResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case movies = "results"
    }
    let page: Int
    let totalPages: Int
    let movies: [MovieDTO]
}

extension MoviesResponseDTO {
    struct MovieDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case id
            case title
            case posterPath = "poster_path"
            case overview
            case releaseDate = "release_date"
        }
        let id: Int
        let title: String
        let posterPath: String?
        let overview: String
        let releaseDate: String?
    }
}

// MARK: - Mappings into Domain

extension MoviesResponseDTO {
    func mapToMoviePage() -> MoviesPage {
        return MoviesPage(page: page,
                          totalPages: totalPages,
                          movies: movies.map { $0.mapToMovie() })
    }
}

extension MoviesResponseDTO.MovieDTO {
    func mapToMovie() -> Movie {
        return Movie(id: MovieId(id),
                     title: title,
                     posterPath: posterPath,
                     overview: overview,
                     releaseDate: dateFormatter.date(from: releaseDate ?? ""))
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()
