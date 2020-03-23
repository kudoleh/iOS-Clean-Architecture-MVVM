//
//  AppDelegate.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var appDIContainer: AppDIContainer? = AppDIContainer()
    var appFlowCoordinator: AppMainFlowCoordinator?
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppAppearance.setupAppearance()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()

        window?.rootViewController = navigationController
        appFlowCoordinator = AppMainFlowCoordinator(navigationController: navigationController,
                                                    appDIContainer: appDIContainer!)
        appFlowCoordinator?.startMoviesSearchFlow()
        window?.makeKeyAndVisible()

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            // your code here
            self.appDIContainer = nil
            self.window?.rootViewController = nil
        }
    
        return true
    }
}
