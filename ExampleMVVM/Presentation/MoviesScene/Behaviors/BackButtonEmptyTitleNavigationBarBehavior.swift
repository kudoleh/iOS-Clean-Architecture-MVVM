//
//  BackButtonEmptyTitleNavigationBarBehavior.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03/04/2020.
//

import UIKit

struct BackButtonEmptyTitleNavigationBarBehavior: ViewControllerLifecycleBehavior {

    func viewDidLoad(viewController: UIViewController) {

        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
