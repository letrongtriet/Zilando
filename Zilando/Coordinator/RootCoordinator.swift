//
//  RootCoordinator.swift
//  Zilando
//
//  Created by Le, Triet on 30.12.2020
//

import UIKit

class RootCoordinator {

    // MARK: - Private properties
    private let window: UIWindow
    private let navigationController: UINavigationController

    // MARK: - Init
    init(window: UIWindow) {
        self.window = window

        navigationController = UINavigationController()
        navigationController.navigationBar.isTranslucent = true
        navigationController.setNavigationBarHidden(false, animated: false)
    }

}

// MARK: - Coordinator
extension RootCoordinator: Coordinator {
    func start() {
        let viewModel = RootViewModel(networkManager: .init(), userDefaultsManager: .init())
        let rootViewController = RootViewController(viewModel: viewModel)

        navigationController.setViewControllers([rootViewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
