//
//  AuthorizationControllerCoordinator.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation
import UIKit

class AuthorizationControllerCoordinator: BaseCoordinator {

    private var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let authController = AuthorizationController()
        authController.authorizationControllerCoordinator = self
        navigationController.pushViewController(authController, animated: true)
    }

    func runRegistration() {
        let registrationControllerCoordinator = RegistrationControllerCoordinator(navigationController: navigationController)
        add(coorfinator: registrationControllerCoordinator)
        registrationControllerCoordinator.start()
    }

    func runTabBar() {
        DispatchQueue.main.async {
            self.navigationController.navigationBar.isHidden = true
        }
        let tabBarControllerCoordinator = TabBarControllerCoordinator(navigationController: navigationController)
        add(coorfinator: tabBarControllerCoordinator)
        tabBarControllerCoordinator.start()
        navigationController.viewControllers.last?.navigationItem.hidesBackButton = true
    }

//    func presentAuth() {
//        navigationController.viewControllers.last
//    }

}
