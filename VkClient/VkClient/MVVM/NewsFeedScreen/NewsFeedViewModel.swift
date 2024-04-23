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
            RealTimeDataBaseManager.shared.obtainNewsFeedPublications { results in
                switch results {
                case .success(let posts):
                    self.publications = StorageManager.sortPublicationsByDate(publications: posts)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }


}
