//
//  TabBarController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit

class TabBarController: UITabBarController {

    weak var tabBarCoordinator: TabBarControllerCoordinator?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configureTabBar(viewControllers: UIViewController...) {
        setViewControllers(viewControllers, animated: true)

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        guard let items = self.tabBar.items else { return }

        items[0].image = UIImage(systemName: "newspaper.circle")
        items[1].image = UIImage(systemName: "person.2")
        items[2].image = UIImage(systemName: "person.circle")
    }
}
