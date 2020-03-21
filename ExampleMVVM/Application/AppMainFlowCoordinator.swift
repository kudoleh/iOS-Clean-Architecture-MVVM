//
//  AppFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit

class AppMainFlowCoordinator {

    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController,
         appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        let makeMoviesSceneDIContainer = appDIContainer.makeMoviesSceneDIContainer()
        let flow = MoviesSearchFlowCoordinator(navigationController: navigationController,
                                               dependencies: makeMoviesSceneDIContainer)
        flow.start()
    }
}
