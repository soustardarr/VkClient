//
//  CoreDataManager.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 18.04.2024.
//

import Foundation
import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    private init() { }

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VkClient")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func saveProfileInfo(with user: User) {
        let userCoreData = EntityUser(context: viewContext)
        userCoreData.name = user.name
        userCoreData.profilePicture = user.profilePicture
        userCoreData.email = user.email
        userCoreData.safeEmail = user.safeEmail
        userCoreData.profilePictureFileName = user.profilePictureFileName
        saveContext()
    }

    func obtainSavedProfileInfo() -> User? {
        let userFetch = EntityUser.fetchRequest()
        do {
            let userFromCoreData = try viewContext.fetch(userFetch)
            guard let user = userFromCoreData.first else {
                return nil
            }

            let dataUser = User(name: user.name ?? "",
                                        email: user.email ?? "",
                                        profilePicture: user.profilePicture ?? Data())
            return dataUser
        } catch {
            print("Ошибка при получении данных из Core Data: \(error)")
            return nil
        }
    }


    func deleteAllUsers() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "EntityUser")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: viewContext)
            saveContext()

            viewContext.reset()
        } catch {
            print("Ошибка при удалении всех пользователей из Core Data: \(error)")
        }
    }

}

