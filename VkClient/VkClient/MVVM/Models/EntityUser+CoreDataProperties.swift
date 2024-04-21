//
//  EntityUser+CoreDataProperties.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 19.04.2024.
//
//

import Foundation
import CoreData


extension EntityUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityUser> {
        return NSFetchRequest<EntityUser>(entityName: "EntityUser")
    }

    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var profilePicture: Data?
    @NSManaged public var profilePictureFileName: String?
    @NSManaged public var safeEmail: String?

}

extension EntityUser : Identifiable {

}
