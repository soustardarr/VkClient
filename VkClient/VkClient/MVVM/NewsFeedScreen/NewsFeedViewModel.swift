//
//  NewsFeedViewModel.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 21.04.2024.
//



import Foundation
import UIKit
import Combine

class NewsFeedViewModel {

    @Published var publications: [Publication] = []

    func getNewsFromFriends() {
        
        DispatchQueue.global().async {
            RealTimeDataBaseManager.shared.obtainUserPublication { results in
                switch results {
                case .success(let posts):
                    self.publications = self.sortPublicationsByDate(publications: posts)
                    print(self.publications)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func sortPublicationsByDate(publications: [Publication]) -> [Publication] {
        let sortedPublications = publications.sorted { (publication1, publication2) -> Bool in
            // Парсим дату публикации и сравниваем их
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm dd.MM.yyyy"
            if let date1 = dateFormatter.date(from: publication1.date),
               let date2 = dateFormatter.date(from: publication2.date) {
                return date1 > date2 // Здесь изменено на date1 > date2 для сортировки от новой к старой дате
            }
            return false
        }
        return sortedPublications
    }

}
