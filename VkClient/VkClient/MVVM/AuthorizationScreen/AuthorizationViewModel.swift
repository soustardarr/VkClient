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
        guard let login = email,
              let password = password,
              !login.isEmpty,
              !password.isEmpty,
              password.count >= 6
        else {
            completion(false)
            return
        }

        FirebaseAuth.Auth.auth().signIn(withEmail: login, password: password) { authResult, error in
            guard let _ = authResult, error == nil else {
                completion(false)
                return
            }
            UserDefaults.standard.set(login, forKey: "email")
//            let queue = DispatchQueue.global(qos: .default)
//            let workItem = DispatchWorkItem {
                RealTimeDataBaseManager.shared.getSelfProfileInfo { result in
                    switch result {
                    case .success(let user):
                        print(user)
//                        CoreDataManager.shared.saveProfileInfo(with: user)
                    }
                }
//            }
//            queue.async(execute: workItem)
//            workItem.notify(queue: .main, execute: {
                completion(true)
//            })
        }

    }

}