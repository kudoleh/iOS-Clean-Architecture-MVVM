//
//  APIEndpoints.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct APIEndpoints {
    
    static func getMovies(query: String, page: Int) -> Endpoint<MoviesPage> {
        
        return Endpoint(path: "3/search/movie/",
                        queryParameters: ["query": query,
                                          "page": "\(page)"])
    }
    
    static func getMoviePoster(path: String, width: Int) -> Endpoint<Data> {
        
        let sizes = [92, 185, 500, 780]
        let closestWidth = sizes.enumerated().min { abs($0.1 - width) < abs($1.1 - width) }?.element ?? sizes.first!
        
        return Endpoint(path: "t/p/w\(closestWidth)\(path)",
                        responseDecoder: RawDataResponseDecoder())
    }
}
