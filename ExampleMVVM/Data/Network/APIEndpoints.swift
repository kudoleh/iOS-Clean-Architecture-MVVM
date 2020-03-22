//
//  APIEndpoints.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct APIEndpoints {
    
    static func getMovies(moviesRequestDTO: MoviesRequestDTO) -> Endpoint<MoviesResponseDTO> {

        return Endpoint(path: "3/search/movie/",
                        method: .get,
                        queryParameters: moviesRequestDTO.toDictionary())
    }
    
    static func getMoviePoster(path: String, width: Int) -> Endpoint<Data> {

        let sizes = [92, 154, 185, 342, 500, 780]
        let closestWidth = sizes.enumerated().min { abs($0.1 - width) < abs($1.1 - width) }?.element ?? sizes.first!
        
        return Endpoint(path: "t/p/w\(closestWidth)\(path)",
                        method: .get,
                        responseDecoder: RawDataResponseDecoder())
    }
}

extension Encodable {
    func toDictionary() -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(self)
            let josnData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return josnData ?? [:]
        } catch {
             #if DEBUG
            print("\(error)")
            #endif
            return [:]
        }
    }
}
