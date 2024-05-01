//
//  AppDelegate.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 29.04.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return true }
        
        let viewController = QuotesViewController()
        window.rootViewController = viewController
        
        window.makeKeyAndVisible()

        return true
    }
}

