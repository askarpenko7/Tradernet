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

    private lazy var repository: QuotesRepositoryContract = {
        let quotesWebSocketManager = QuotesWebSocketManager()
        let storageManager = QuotesStorageManager()
        return QuotesRepository(webSocketManager: quotesWebSocketManager, storageManager: storageManager)
    }()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        guard let window = window else { return true }

        if isFirstLaunch() {
            let tickers = PreloadedDataHelper.fetchPreloadedData()
            repository.save(tickers: tickers)
        }

        let viewModel = QuotesViewModel(repository: repository)
        let viewController = QuotesViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .mainBackground
            appearance.titleTextAttributes = [.foregroundColor: UIColor.primaryText]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryText]

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = .mainBackground
            UINavigationBar.appearance().tintColor = .systemBlue
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.primaryText]
            UINavigationBar.appearance().isTranslucent = false
        }

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        return true
    }

    // MARK: Preload data

    func isFirstLaunch() -> Bool {
        let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
}
