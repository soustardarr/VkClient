//
//  TabBarControllerCoordinator.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation
import UIKit

class TabBarControllerCoordinator: BaseCoordinator {
    private var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let tabBar = TabBarController()
        tabBar.tabBarCoordinator = self
        let newsFeedController = NewsFeedController()
        let friendsController = FriendsController()
        let profileController = ProfileController()
        tabBar.configureTabBar(viewControllers: newsFeedController, friendsController, profileController)
        navigationController.pushViewController(tabBar, animated: true)
    }
}
