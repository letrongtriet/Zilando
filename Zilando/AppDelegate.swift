//
//  AppDelegate.swift
//  Zilando
//
//  Created by Le, Triet on 30.12.2020 on 30.12.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        // Make sure we have time to prepare for DARK MODE
        window?.overrideUserInterfaceStyle = .light

        appCoordinator = AppCoordinator(window: window!)
        appCoordinator.start()

        return true
    }

}

