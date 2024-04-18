//
//  RealTimeDataBaseManager.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation
import FirebaseDatabase
import UIKit

class RealTimeDataBaseManager {
    
    static let shared = RealTimeDataBaseManager()

    private let database = Database.database().reference()

    static func safeEmail(emailAddress: String) -> String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: ",")
        return safeEmail
    }

}


extension RealTimeDataBaseManager {

    //MARK: ПРОВЕРКА НА СУЩЕВСТОВАНИЕ ЮЗЕРА
    func userExists(with email: String, completion: @escaping ((Bool) -> (Void))) {
        let safeEmail = email.replacingOccurrences(of: ".", with: ",")
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            if let userDict = snapshot.value as? [String: String], let _ = userDict["name"] {
                completion(true)
                print("пользователь есть, передаем true")
            } else {
                print("пользователя нет, передаем false")
                completion(false)
            }
        })
    }

    //MARK: ВСТАВКА ЮЕЗЕРА В БД
    func insertUser(with user: User, completion: @escaping (Bool) -> ()) {
        database.child(user.safeEmail).setValue(["name": user.name,
                                                 "email": user.email,
                                                 "safeEmail": user.safeEmail,
                                                 "profilePictureFileName": user.profilePictureFileName ]) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    //MARK: ПОЛУЧЕНИЕ ИНФОРМАЦИИ О СВОЕМ ПРОФИЛЕ
    func getSelfProfileInfo(completionHandler: @escaping (Result<User, Never>) -> ()) {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            print("UserDefaults ПУСТ ПУСТ ПУСТ")
            return
        }
        let safeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            print("\(Thread.current)")
            if let userDict = snapshot.value as? [String: Any],
               let userName = userDict["name"] as? String {
                StorageManager.shared.downloadAvatarDataSelfProfile()
                StorageManager.shared.getAvatarData = { data in
                    let user = User(name: userName, email: email, profilePicture: data)
                    completionHandler(.success(user))
                }
            } else {
                print("Неизвестный формат снимка данных")
            }
        }
    }


}
