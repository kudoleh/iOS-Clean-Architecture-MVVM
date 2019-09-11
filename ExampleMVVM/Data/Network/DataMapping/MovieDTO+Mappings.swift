//
//  MovieDTO+Mappings.swift
//  Data
//
//  Created by Oleh Kudinov on 12.08.19.
//  Copyright © 2019 Oleh Kudinov. All rights reserved.
//

import Foundation

// Data Transfer Object
struct MoviesPageDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case results
    }
    let page: Int
    let totalPages: Int
    let results: [MovieDTO]
}

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

extension MoviesPageDTO {
    func mapToMoviePage() -> MoviesPage {
        return MoviesPage(page: page,
                          totalPages: totalPages,
                          movies: results.map { $0.mapToMovie() })
    }
}

extension MovieDTO {
    func mapToMovie() -> Movie {
        return Movie(id: MovieId(id),
                     title: title,
                     posterPath: posterPath,
                     overview: overview,
                     releaseDate: DateFormatter.yyyyMMdd.date(from: releaseDate ?? ""))
    }
}

fileprivate extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
