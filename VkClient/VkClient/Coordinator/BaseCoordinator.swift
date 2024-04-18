//
//  BaseCoordinator.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation

class BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    func start() {
        fatalError("каждый наследник должен иметь этот метод")
    }

    func dismissToLastVC() {

    }


}
