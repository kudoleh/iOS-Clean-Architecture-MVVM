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
        
        let apiDataNetwork = DefaultNetworkService(sessionManager: networkSessionManager,
                                                   config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    lazy var imageDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.imagesBaseURL)!)
        let carrierLogosDataNetwork = DefaultNetworkService(sessionManager: networkSessionManager,
                                                            config: config)
        return DefaultDataTransferService(with: carrierLogosDataNetwork)
    }()
    lazy var networkSessionManager = DefaultNetworkSessionManager()
    
    // DIContainers of scenes
    func makeMoviesSceneDIContainer() -> MoviesSceneDIContainer {
        let dependencies = MoviesSceneDIContainer.Dependencies(apiDataTransferService: apiDataTransferService,
                                                               imageDataTransferService: imageDataTransferService)
        return MoviesSceneDIContainer(dependencies: dependencies)
    }
}
