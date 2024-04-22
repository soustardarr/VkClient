//
//  RegistrationViewModel.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation
import UIKit
import FirebaseAuth

class RegistrationViewModel {
    func didRegisteredUser(_ name: String?, _ email: String?, _ password: String?, _ secondPassword: String?, _ avatar: UIImage?,
                           completion: @escaping (_ boolResult: Bool, _ message: String?) -> ()) {
        guard let name = name, let login = email,
              let password = password, let secondPassword = secondPassword,
              let image = avatar,
              !login.isEmpty,
              !password.isEmpty,
              !secondPassword.isEmpty,
              !name.isEmpty,
              password == secondPassword,
              password.count >= 6,
              name.count >= 3
        else {
            completion(false, "проверьте правильность введенной информации")
            return
        }
        let queue = DispatchQueue.global(qos: .default)

        let workItem = DispatchWorkItem {
            RealTimeDataBaseManager.shared.userExists(with: login) { exists in
                if exists {
                    completion(false, "пользователь с таким email уже существует")
                } else {
                    completion(true, nil)
                    let user = User(name: name, email: login)
//                    DispatchQueue.global().async {
                        FirebaseAuth.Auth.auth().createUser(withEmail: login, password: password) { dataResult, error in
                            guard dataResult != nil, error == nil else {
                                completion(false, "не удалось создать пользователя")
                                return
                            }
                            print("создана учетная запись")
                            // Выход из учетной записи
                            do {
                                try FirebaseAuth.Auth.auth().signOut()
                            } catch let signOutError as NSError {
                                print("Ошибка при выходе из учетной записи: \(signOutError.localizedDescription)")
                            }

                        }
                        RealTimeDataBaseManager.shared.insertUser(with: user) { result in
                            if result {
                                print("успешная вставка юзера в бд")
                            }
                        }
                        StorageManager.shared.uploadImage(with: image.pngData() ?? Data(), fileName: user.profilePictureFileName) { result in
                            switch result {
                            case .success(let downloadUrl):
                                // UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print("ссылка на скачивание: \(downloadUrl)")
                            case .failure(let error):
                                print("ошибка хранилища: \(error)")
                            }
                        }
//                    }

                }
            }
        }

        queue.async(execute: workItem)
    }
}
