//
//  FriendsViewModel.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import Foundation
import Combine
import UIKit


class FriendsViewModel {

    @Published var results: [User]?

    @Published var users = [User]()
    var hasFetched = false

    func searchUsers(text: String) {
        if hasFetched {
            filterUsers(text)
        } else {
            RealTimeDataBaseManager.shared.getAllUsers { [ weak self ] result in
                switch result {
                case .success(let users):
                    self?.hasFetched = true
                    self?.users = users
                    self?.filterUsers(text)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func filterUsers(_ text: String) {
        guard hasFetched else {
            return
        }
//        let selfUser = CoreDataManager.shared.obtainSavedProfileInfo()
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let safeEmail  = RealTimeDataBaseManager.safeEmail(emailAddress: email)
        var resultUsers: [User] = self.users.filter {
            return $0.name.lowercased().hasPrefix(text.lowercased())
        }
        resultUsers.removeAll(where: { $0.safeEmail == safeEmail})
        guard !resultUsers.isEmpty else {
            return
        }
        self.results = resultUsers
    }


}


