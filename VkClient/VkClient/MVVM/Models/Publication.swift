//
//  Publication.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 21.04.2024.
//

import Foundation
import UIKit

struct Publication {
    var id = UUID()
    var avatarImage: UIImage?
    var avatarImageFileName: String?
    var publiactionImageData: Data?
    var publiactionPictureFileName: String {
        return "\(id)_publication_picture.png"
    }
    var name: String?
    var text: String?
    var date: String
    var like: Like?
}

struct Like {
    var count: Int?
    var likedByCurrentUser: Bool
    
    mutating func toggleLiked() {
        likedByCurrentUser.toggle()
    }
}
