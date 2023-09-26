//
//  AppDelegate.swift
//  LearnMetal
//
//  Created by ONEMC on 2023/8/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController.init(rootViewController: vcForRenders() )
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }
}

