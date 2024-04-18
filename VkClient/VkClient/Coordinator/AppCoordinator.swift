//
//  AppCoordinator.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation
import UIKit
import FirebaseAuth

class AppCoordinator: BaseCoordinator {

    private var window: UIWindow

    private var navigationController: UINavigationController = {
        let navigationContoller = UINavigationController()
        return navigationContoller
    }()

    init(window: UIWindow) {
        self.window = window
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()
    }

    override func start() {
        if FirebaseAuth.Auth.auth().currentUser != nil {
            let tabBarCoordinator = TabBarControllerCoordinator(navigationController: navigationController)
            add(coorfinator: tabBarCoordinator)
            tabBarCoordinator.start()

        } else {
            let authorizationViewContollerCoordinator = AuthorizationControllerCoordinator(navigationController: navigationController)
            add(coorfinator: authorizationViewContollerCoordinator)
            authorizationViewContollerCoordinator.start()
        }
    }

}
