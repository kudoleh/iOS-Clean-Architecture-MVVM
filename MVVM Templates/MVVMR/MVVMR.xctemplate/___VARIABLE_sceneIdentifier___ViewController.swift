//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ All rights reserved.
//

import UIKit

class ___VARIABLE_sceneIdentifier___ViewController: UIViewController, StoryboardInstantiable {
    
    var viewModel: ___VARIABLE_sceneIdentifier___ViewModel!
    
    class func create(with viewModel: ___VARIABLE_sceneIdentifier___ViewModel) -> ___VARIABLE_sceneIdentifier___ViewController {
        let vc = ___VARIABLE_sceneIdentifier___ViewController.instantiateViewController()
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    func bind(to viewModel: ___VARIABLE_sceneIdentifier___ViewModel) {
        viewModel.route.observe(on: self) { [weak self] route in
            self?.handle(route)
        }
    }
}

// MARK: - Perform Routing

extension ___VARIABLE_sceneIdentifier___ViewController {
    func handle(_ route: ___VARIABLE_sceneIdentifier___ViewModelRoute?) {
        guard let route = route else { return }
        switch route {
        case .showDetails(let itemId):
            // present view
            break
        }
    }
}
