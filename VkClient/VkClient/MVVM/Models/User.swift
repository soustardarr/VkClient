//
//  User.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation

struct User: Codable {
    var name: String
    var email: String
    var safeEmail: String {
        let safeEmail = email.replacingOccurrences(of: ".", with: ",")
        return safeEmail
    }
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    var profilePicture: Data?
    var friends: [String]?
    var followers: [String]?
    var subscriptions: [String]?
}
