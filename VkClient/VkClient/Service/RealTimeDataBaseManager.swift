//
//  RealTimeDataBaseManager.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation
import FirebaseDatabase
import UIKit
import Combine

enum RealTimeDataBaseError: Error {
    case failedProfile
    case failedReceivingUsers
    case failedReceivingFriends
}

class RealTimeDataBaseManager {
    
    static let shared = RealTimeDataBaseManager()

    private let database = Database.database().reference()

    @Published var currentUser: User?


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
    func getSelfProfileInfo(completionHandler: @escaping (Result<User, Error>) -> ()) {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            print("UserDefaults ПУСТ ПУСТ ПУСТ")
            return
        }
        let dispatchQueue = DispatchQueue.global(qos: .default)
        let group = DispatchGroup()
        let safeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
        var user = User(name: "", email: email)


        let observeSingleSnapshot = DispatchWorkItem {
            group.enter()
            self.database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
                if let userDict = snapshot.value as? [String: Any],
                   let userName = userDict["name"] as? String {
                    print("\(Thread.current) записано имя!!!!")
                    user.name = userName
                    group.leave()
                } else {
                    completionHandler(.failure(RealTimeDataBaseError.failedProfile))
                    print("Неизвестный формат снимка данных")
                    group.leave()
                }
            }
        }
        let downloadAvatarDataSelfProfile = DispatchWorkItem {
            StorageManager.shared.downloadAvatarDataSelfProfile { result in
                guard result else {
                    user.profilePicture = nil
                    completionHandler(.success(user))
                    return
                }
                print("\(Thread.current) получена фотка!!!!!")
            }
            StorageManager.shared.getAvatarData = { data in
                user.profilePicture = data
                completionHandler(.success(user))
            }
        }

        dispatchQueue.async(group: group, execute: observeSingleSnapshot)
        group.notify(queue: dispatchQueue, work: downloadAvatarDataSelfProfile)

    }


    //MARK: ПОЛУЧЕНИЕ ВСЕХ ЮЗЕРОВ
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> ()) {
        database.observeSingleEvent(of: .value) { snapshot in
            guard let childrensJson = snapshot.value as? [String: Any] else {
                completion(.failure(RealTimeDataBaseError.failedReceivingUsers))
                return
            }
            var users: [User] = []
            for (_, value) in childrensJson {
                if let userDict = value as? [String: Any] {
                    let name = userDict["name"] as? String
                    let email = userDict["email"] as? String
                    let friends = userDict["friends"] as? [String]
                    let followers = userDict["followers"] as? [String]
                    let subscriptions = userDict["subscriptions"] as? [String]
                    let user = User(name: name ?? "", email: email ?? "",
                                                friends: friends, followers: followers, subscriptions: subscriptions)
                    users.append(user)
                }
            }
            completion(.success(users))
        }
    }
}


// MARK: - User Subscription Status Manager

extension RealTimeDataBaseManager {
    // currentUser - тот на кого подписываемся
    // selfUser - аккаунт с которого подписываемся

    //MARK: ДОБАВЛЕНИЕ ПОДПИСКИ
    func addFollow(for currentUser: User, completion: @escaping (User?) -> Void) {
//        let selfUser = CoreDataManager.shared.obtainSavedProfileInfo()
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let selfSafeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
        var currentUser = User(name: currentUser.name,
                                  email: currentUser.email,
                                  friends: currentUser.friends,
                                  followers: currentUser.followers,
                                  subscriptions: currentUser.subscriptions)
        // добавляем подписчика current user
        database.child(currentUser.safeEmail)
            .child("followers")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var followers = snapshot.value as? [String] {
                    followers.append(selfSafeEmail)
                    currentUser.followers = followers
                    strongSelf.database.child(currentUser.safeEmail).child("followers").setValue(followers)
                    completion(currentUser)
                } else {
                    let followers: [String] = [selfSafeEmail]
                    currentUser.followers?.append(selfSafeEmail)
                    strongSelf.database.child("\(currentUser.safeEmail)/followers").setValue(followers)
                    currentUser.followers = followers
                    completion(currentUser)
                }
            }
        // добавляем подписку на кого то selfuser'у
        database.child(selfSafeEmail)
            .child("subscriptions")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var subscriptions = snapshot.value as? [String] {
                    subscriptions.append(currentUser.safeEmail)
                    strongSelf.database.child(selfSafeEmail).child("subscriptions").setValue(subscriptions)
                } else {
                    let subscriptions = [ currentUser.safeEmail ]
                    strongSelf.database.child("\(selfSafeEmail)/subscriptions").setValue(subscriptions)
                }
            }
    }

    //MARK: УДАЛЕНИЕ ПОДПИСКИ
    func deleteFollow(for currentUser: User, completion: @escaping (User?) -> Void) {
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let selfSafeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
//        let selfUser = CoreDataManager.shared.obtainSavedProfileInfo()
        // удаляем подписку selfuser
        database.child(selfSafeEmail)
            .child("subscriptions")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var subscriptions = snapshot.value as? [String] {
                    print(subscriptions)
                    subscriptions.removeAll(where: { $0 == currentUser.safeEmail})
                    strongSelf.database
                        .child(selfSafeEmail)
                        .child("subscriptions").setValue(subscriptions)
                }
            }
        // удаляем подписчика current user
        var currentUser = User(name: currentUser.name,
                                  email: currentUser.email,
                                  friends: currentUser.friends,
                                  followers: currentUser.followers,
                                  subscriptions: currentUser.subscriptions)
        database.child(currentUser.safeEmail)
            .child("followers")
            .observeSingleEvent(of: .value) {[ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var followers = snapshot.value as? [String] {
                    followers.removeAll(where: { $0 == selfSafeEmail})
                    currentUser.followers = followers
                    strongSelf.database.child(currentUser.safeEmail).child("followers").setValue(followers)
                    completion(currentUser)
                }
            }
    }

    func deleteFromFriendList(_ selfEmail: String, _ currentUserEmail: String) {
        // удаляем у себя друга
        database.child(selfEmail)
            .child("friends")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var friends = snapshot.value as? [String] {
                    friends.removeAll(where: { $0 == currentUserEmail})
                    strongSelf.database.child(selfEmail).child("friends").setValue(friends)
                }
            }
        // удаляем currentusery себя из друзей
        database.child(currentUserEmail)
            .child("friends")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var friends = snapshot.value as? [String] {
                    friends.append(selfEmail)
                    friends.removeAll(where: { $0 == selfEmail})
                    strongSelf.database.child(currentUserEmail).child("friends").setValue(friends)
                }
            }
    }

    func addToFriendsList(_ selfEmail: String, _ currentUserEmail: String) {
        // добавляем себе в друзья
        database.child(selfEmail)
            .child("friends")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var friends = snapshot.value as? [String] {
                    friends.append(currentUserEmail)
                    strongSelf.database.child(selfEmail).child("friends").setValue(friends)
                } else {
                    let friends: [String] = [ currentUserEmail ]
                    strongSelf.database.child("\(selfEmail)/friends").setValue(friends)
                }
            }
        // добавляем current usery себя ему в друзья
        database.child(currentUserEmail)
            .child("friends")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var friends = snapshot.value as? [String] {
                    friends.append(selfEmail)
                    strongSelf.database.child(currentUserEmail).child("friends").setValue(friends)
                } else {
                    let friends = [ selfEmail ]
                    strongSelf.database.child("\(currentUserEmail)/friends").setValue(friends)
                }
            }
    }



}
