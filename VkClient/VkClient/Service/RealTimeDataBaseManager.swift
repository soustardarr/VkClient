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
    case failedReceivingPublication
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

    func getEmailFriends(safeEmail: String, completion: @escaping (Result<[String], Error>) -> Void) {
        database.child(safeEmail).child("friends").observeSingleEvent(of: .value) { snapshot in
            if let friends = snapshot.value as? [String] {
                completion(.success(friends))
            } else {
                completion(.failure(RealTimeDataBaseError.failedReceivingFriends))
            }
        }
    }


    func getPeopleProfileInfoWithSafeEmail(safeEmail: String, completionHandler: @escaping (Result<User, Error>) -> ()) {
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            if let userDict = snapshot.value as? [String: Any],
               let name = userDict["name"] as? String,
               let profilePictureFileName = userDict["profilePictureFileName"] as? String,
               let email = userDict["email"] as? String,
               let friends = userDict["friends"] as? [String],
               let followers = userDict["followers"] as? [String],
               let subscriptions = userDict["subscriptions"] as? [String],
               let publicationsDict = userDict["publications"] as? [String: Any] {
                var publications: [Publication] = []
                for (_, value) in publicationsDict {
                    if let publicationDict = value as? [String: Any] {
                        let idString = publicationDict["id"] as? String
                        let id = UUID(uuidString: idString ?? "")
                        let text = publicationDict["text"] as? String
                        let date = publicationDict["date"] as? String
                        let publication = Publication(id: id ?? UUID(), text: text ?? "", date: date ?? "")
                        publications.append(publication)
                    }
                }
                StorageManager.shared.downloadImage(profilePictureFileName) { result in
                    switch result {
                    case .success(let data):
                        let returnUser = User(name: name, email: email, profilePicture: data, friends: friends, followers: followers, subscriptions: subscriptions, publiсations: publications)
                        completionHandler(.success(returnUser))
                    case .failure(let error):
                        completionHandler(.failure(error))
                    }
                }
            } else {
                completionHandler(.failure(RealTimeDataBaseError.failedReceivingUsers))
                print("Неизвестный формат снимка данных")
            }
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


// MARK: - set publication

extension RealTimeDataBaseManager {

    func sendPublication(publication: Publication) {
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let selfSafeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)

        database.child(selfSafeEmail)
            .child("publications")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var publications = snapshot.value as? [String: Any] {
                    let publicationData: [String: String] = [
                        "publiactionPictureFileName": publication.publiactionPictureFileName,
                        "date": publication.date,
                        "text": publication.text ?? "",
                        "id": publication.id.uuidString
                    ]
                    publications["\(publication.id)"] = publicationData
                    strongSelf.database.child(selfSafeEmail).child("publications").setValue(publications)
                    print("успешное добавление публикации")
                } else {
                    let publicationData: [String: String] = [
                        "publiactionPictureFileName": publication.publiactionPictureFileName,
                        "date": publication.date,
                        "text": publication.text ?? "",
                        "id": publication.id.uuidString
                    ]
                    var publications: [String: Any] = [:]
                    publications["\(publication.id)"] = publicationData
                    strongSelf.database.child("\(selfSafeEmail)/publications").setValue(publications)
                    print("успешная вствака первой публикации")
                }
            }
    }

    // метод большой, извиняюсь за эту глупость(я один понимаю что тут написано((( )
    func obtainUserPublication(completion: @escaping (Result<[Publication], Error>) -> Void) {
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let safeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
        var friendEmails: [String] = []
        let serialQueue = DispatchQueue(label: "obtainUserPublication")
        let group = DispatchGroup()
        var users: [User] = []
        let getEmailFriendsItem = DispatchWorkItem {
            RealTimeDataBaseManager.shared.getEmailFriends(safeEmail: safeEmail) { result in
                switch result {
                case .success(let emails):
                    friendEmails = emails
                    print(friendEmails)
                    group.leave()
                case .failure(let error):
                    print("ОШИБКА ПОЛУЧЕНИЯ УМАЙЛОВ ДРУЗЕЙ \(error)")
                    completion(.failure(error))
                    group.leave()
                }
            }
        }
        let getPeopleProfileInfoItem = DispatchWorkItem {
            print("getPeopleProfileInfoItem!!!1")
            for friendEmail in friendEmails {
                print("\(Thread.current) !!!!!!!!")
                group.enter()
                RealTimeDataBaseManager.shared.getPeopleProfileInfoWithSafeEmail(safeEmail: friendEmail) { result in
                    print("\(Thread.current) !!!!!!!!")
                    switch result {
                    case .success(let user):
                        users.append(user)
                        group.leave()
                    case .failure(let error):
                        completion(.failure(error))
                        group.leave()
                    }
                }
            }
            group.leave()
        }

        let completionItem = DispatchWorkItem {
            var publications: [Publication] = []
            for user in users {
                guard let userPublications = user.publiсations else { return }
                group.enter()
                for post in userPublications {
                    group.enter()
                    StorageManager.shared.downloadImage(post.publiactionPictureFileName) { result in
                        switch result {
                        case .success(let data):
                            let publication = Publication(id: post.id,
                                                          avatarImage: UIImage(data: user.profilePicture ?? Data()),
                                                          publiactionImageData: data,
                                                          name: user.name,
                                                          text: post.text,
                                                          date: post.date)
                            publications.append(publication)
                            group.leave()
                        case .failure(let error):
                            completion(.failure(error))
                            group.leave()
                        }

                    }
                }
                group.leave()

            }
            group.leave()
            group.notify(queue: serialQueue) {
                completion(.success(publications))

            }
        }

        group.enter()
        serialQueue.async(execute: getEmailFriendsItem)
        group.notify(queue: serialQueue) {
            group.enter()
            serialQueue.async(execute: getPeopleProfileInfoItem)
            group.notify(queue: serialQueue) {
                group.enter()
                serialQueue.async(execute: completionItem)
            }
        }
        group.wait()

    }





}

