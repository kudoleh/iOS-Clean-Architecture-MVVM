//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ All rights reserved.
//

import Foundation

enum ___VARIABLE_sceneIdentifier___ViewModelRoute {
    case showDetails(itemId: String)
}

protocol ___VARIABLE_sceneIdentifier___ViewModelInput {
    func viewDidLoad()
}

protocol ___VARIABLE_sceneIdentifier___ViewModelOutput {
    var route: Observable<___VARIABLE_sceneIdentifier___ViewModelRoute?> { get }
}

protocol ___VARIABLE_sceneIdentifier___ViewModel: ___VARIABLE_sceneIdentifier___ViewModelInput, ___VARIABLE_sceneIdentifier___ViewModelOutput { }

class Default___VARIABLE_sceneIdentifier___ViewModel: ___VARIABLE_sceneIdentifier___ViewModel {
    
    // MARK: - OUTPUT
    private(set) var route: Observable<___VARIABLE_sceneIdentifier___ViewModelRoute?> = Observable(nil)
}

// MARK: - INPUT. View event methods
extension Default___VARIABLE_sceneIdentifier___ViewModel {
    func viewDidLoad() { }
}
