//
//  PeopleProfileViewModel.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import Foundation
import Combine

enum FriendStatus {
    case selfSubscribed
    case heSubscribedForSelf
    case inFriends
    case cleanStatus
}

class PeopleProfileViewModel {


    @Published var currentUser: User
    let selfEmail = RealTimeDataBaseManager.safeEmail(emailAddress: UserDefaults.standard.string(forKey: "email") ?? "")

    
    init(currentUser: User) {
        self.currentUser = currentUser
    }

    func changeFriendStatus() {
        let status = checkFriendStatus(with: currentUser)
        switch status {
        case .selfSubscribed:
            RealTimeDataBaseManager.shared.deleteFromFriendList(selfEmail, currentUser.safeEmail)
            RealTimeDataBaseManager.shared.deleteFollow(for: currentUser) { user in
                guard let user = user else {
                    print("user = nil")
                    return
                }
                self.currentUser = user
            }
        case .heSubscribedForSelf:
            RealTimeDataBaseManager.shared.addToFriendsList(selfEmail, currentUser.safeEmail)
            RealTimeDataBaseManager.shared.addFollow(for: currentUser) { user in
                guard let user = user else {
                    print("user = nil")
                    return
                }
                self.currentUser = user
            }
        case .inFriends:
            RealTimeDataBaseManager.shared.deleteFromFriendList(selfEmail, currentUser.safeEmail)
            RealTimeDataBaseManager.shared.deleteFollow(for: currentUser) { user in
                guard let user = user else {
                    print("user = nil")
                    return
                }
                self.currentUser = user
            }
            print()
        case .cleanStatus:
            RealTimeDataBaseManager.shared.addFollow(for: currentUser) { user in
                guard let user = user else {
                    print("user = nil")
                    return
                }
                self.currentUser = user
            }
        }
    }

    func checkFriendStatus(with user: User) -> FriendStatus {

        if let currentUserFollowers = user.followers,
           let currentUserSubscriptions = user.subscriptions,// в друзьях ли мы
           currentUserFollowers.contains(where: {$0 == selfEmail }),
           currentUserSubscriptions.contains(where: {$0 == selfEmail }) {
            return .inFriends
        } else if let currentUserFollowers = user.followers, // подписан ли я на него
                  currentUserFollowers.contains(where: {$0 == selfEmail }) {
            return .selfSubscribed
        } else if let currentUserSubscriptions = user.subscriptions, // подписан ли он на меня
                  currentUserSubscriptions.contains(where: { $0 == selfEmail }){
            return .heSubscribedForSelf
        } else {
            return .cleanStatus
        }
    }


}

