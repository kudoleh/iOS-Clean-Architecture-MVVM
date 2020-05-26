//
//  BlackStyleNavigationBarBehavior.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 26/05/2020.
//

import UIKit

struct BlackStyleNavigationBarBehavior: ViewControllerLifecycleBehavior {

    func viewDidLoad(viewController: UIViewController) {

        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
