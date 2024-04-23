//
//  ProfileViewModel.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import Foundation
import FirebaseAuth
import UIKit

class ProfileViewModel {
    
    func getProfile(returnUser: @escaping (User?) -> Void) {
        RealTimeDataBaseManager.shared.getSelfProfileInfoWithPublications { result in
            switch result {
            case .success(let user):
                returnUser(user)
            case .failure(let error):
                print("ошибка получения профиля\(error)")
            }
        }


    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "email")
        CoreDataManager.shared.deleteAllUsers()
        do {
            try FirebaseAuth.Auth.auth().signOut()
            AppCoordinator.shared.start()
        } catch let error {
            print(error)
        }
    }

}
