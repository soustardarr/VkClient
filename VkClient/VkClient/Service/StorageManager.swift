//
//  StorageManager.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation
import FirebaseStorage

public enum StorageErorrs: Error {
    case failedToUpload
    case failedToGetDownloadURL
}

class StorageManager {

    static let shared = StorageManager()

    private let storage = Storage.storage().reference()


    var avatarData: Data? {
        didSet {
            getAvatarData?(avatarData)
        }
    }

    var getAvatarData: ((Data?) -> ())?
}


extension StorageManager {


    func uploadAvatarImage(with data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> ()) {

        storage.child("images/\(fileName)").putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                completion(.failure(StorageErorrs.failedToUpload))
                return
            }

            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(StorageErorrs.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }


    func downloadAvatarDataSelfProfile(completion: @escaping (Bool) -> ()) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"

        let path = "images/" + fileName

        getDownloadUrl(for: path) { result in
            switch result {
            case .success(let url):
                URLSession.shared.dataTask(with: url) { data, _, error in
                    print("\(Thread.current) ПОТОК URLSession")
                    guard let data = data, error == nil else { return }
                    self.avatarData = data
                    completion(true)
                }.resume()
            case .failure(let error):
                completion(false)
                print("не удалось найти ссылку на скачивание, Error: \(error)")
            }

        }
    }

    func downloadAvatarDataOtherUsers(_ photoFileName: String, completionHandler: @escaping (Result<Data?, Error>) -> ()) {
        let path = "images/" + photoFileName
        getDownloadUrl(for: path) { result in
            switch result {
            case .success(let url):
                URLSession.shared.dataTask(with: url) { data, _, error in
                    guard let data = data, error == nil else { return }
                    completionHandler(.success(data))
                }.resume()
            case .failure(let error):
                completionHandler(.failure(error))
            }

        }
    }

    func getDownloadUrl(for path: String, completion: @escaping (Result<URL, Error>) -> ()){
        let reference = storage.child(path)

        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErorrs.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }

}
