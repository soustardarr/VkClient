//
//  AuthorizationViewModel.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation
import FirebaseAuth

class AuthorizationViewModel {

    func didLoginAccount(_ email: String?, _ password: String?, completion: @escaping (Bool) -> ()) {
        CoreDataManager.shared.deleteAllUsers()
        guard let login = email,
              let password = password,
              !login.isEmpty,
              !password.isEmpty,
              password.count >= 6
        else {
            completion(false)
            return
        }
        UserDefaults.standard.set(login, forKey: "email")
        FirebaseAuth.Auth.auth().signIn(withEmail: login, password: password) { authResult, error in
            guard let _ = authResult, error == nil else {
                UserDefaults.standard.removeObject(forKey: "email")
                completion(false)
                return
            }
            RealTimeDataBaseManager.shared.getSelfProfileInfo { result in
                switch result {
                case .success(let user):
                    RealTimeDataBaseManager.shared.currentUser = user
                    CoreDataManager.shared.saveProfileInfo(with: user)
                case .failure(let error):
                    print(error)
                }
            }
            completion(true)
        }

    }

}
