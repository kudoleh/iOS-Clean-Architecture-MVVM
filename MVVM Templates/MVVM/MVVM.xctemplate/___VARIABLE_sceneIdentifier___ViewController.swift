//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ sp. z o.o. All rights reserved.
//

import UIKit

class ___VARIABLE_sceneIdentifier___ViewController: UIViewController, StoryboardInstantiable {
    
    var viewModel: ___VARIABLE_sceneIdentifier___ViewModel!
    
    class func create(with viewModel: ___VARIABLE_sceneIdentifier___ViewModel) -> ___VARIABLE_sceneIdentifier___ViewController {
        let view = ___VARIABLE_sceneIdentifier___ViewController.instantiateViewController()
        view.viewModel.router = Default___VARIABLE_sceneIdentifier___Router(view: view)
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    func bind(to viewModel: ___VARIABLE_sceneIdentifier___ViewModel) {

    }
}
