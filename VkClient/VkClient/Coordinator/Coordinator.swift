//
//  Coordinator.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }

    func start()
}

extension Coordinator {
    func add(coorfinator: Coordinator) {
        childCoordinators.append(coorfinator)
    }

    func remove(coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator}
    }
}
