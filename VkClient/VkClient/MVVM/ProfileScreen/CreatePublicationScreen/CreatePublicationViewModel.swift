//
//  CreatePublicationViewModel.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 21.04.2024.
//

import Foundation
import UIKit

class CreatePublicationViewModel {


    func sendPublicationToFirebase(publication: Publication) {

        let formattedDate = getDate()
       
        let queue = DispatchQueue.global()
        queue.async {
            StorageManager.shared.uploadImage(with: publication.publiactionImageData ?? Data(), fileName: publication.publiactionPictureFileName) { result in
                switch result {
                case .success(let url):
                    print("ссылка на скачивание \(url)")
                case .failure(let error):
                    print("не удалось загрузить фото публикации: \(error)")
                }
            }

            queue.async {
                RealTimeDataBaseManager.shared.sendPublication(publication: publication)
            }
        }


    }

    func getDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd.MM.yyyy"
        return dateFormatter.string(from: Date())
    }

}
