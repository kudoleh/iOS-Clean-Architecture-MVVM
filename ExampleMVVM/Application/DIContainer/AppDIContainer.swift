//
//  DIContainer.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import  UIKit

final class AppDIContainer {
    
    lazy var appConfigurations = AppConfigurations()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.apiBaseURL)!,
                                          queryParameters: ["api_key": appConfigurations.apiKey])
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    lazy var imageDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.imagesBaseURL)!)
        let imagesDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: imagesDataNetwork)
    }()
    
    // DIContainers of scenes
    func makeMoviesSceneDIContainer() -> MoviesSceneDIContainer {
        let dependencies = MoviesSceneDIContainer.Dependencies(apiDataTransferService: apiDataTransferService,
                                                               imageDataTransferService: imageDataTransferService)
        return MoviesSceneDIContainer(dependencies: dependencies)
    }
}
