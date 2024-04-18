//
//  EntityUser+CoreDataProperties.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 18.04.2024.
//
//

import Foundation
import CoreData


extension EntityUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityUser> {
        return NSFetchRequest<EntityUser>(entityName: "EntityUser")
    }

    @NSManaged public var name: String?
    @NSManaged public var safeEmail: String?
    @NSManaged public var profilePictureFileName: String?
    @NSManaged public var profilePicture: Data?
    @NSManaged public var email: String?

}

extension EntityUser : Identifiable {

}
