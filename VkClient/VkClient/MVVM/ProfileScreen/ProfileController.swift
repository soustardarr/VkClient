//
//  ProfileController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit
import Combine

class ProfileController: UIViewController {


    private var profileView: NewsFeedTableView?
    private var headerView: HeaderView?
    private var cancellable: Set<AnyCancellable> = []
    private var profileViewModel: ProfileViewModel?
    private var user: User?
    private var publications: [Publication]?
    private weak var createViewModel: CreatePublicationViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    private func obtainCoreDataProfile() {
        let user = CoreDataManager.shared.obtainSavedProfileInfo()
        headerView?.avatarImageView.image = UIImage(data: user?.profilePicture ?? Data())
        headerView?.nameLabel.text = user?.name
        self.user = user

    }

    private func setup() {
        profileView = NewsFeedTableView()
        view = profileView
        profileView?.newsFeedTable.delegate = self
        profileView?.newsFeedTable.dataSource = self
        profileView?.newsFeedTable.register(NewsFeedTableViewCell.self, forCellReuseIdentifier: NewsFeedTableViewCell.reuseIdentifier)
        headerView = HeaderView()
        headerView?.delegate = self
        obtainOnlyProfileInfo()
        obtainCoreDataProfile()
        profileViewModel = ProfileViewModel()
        obtainProfileFromFirebaseWithPublications()
    }



    private func obtainProfileFromFirebaseWithPublications() {

        RealTimeDataBaseManager.shared.getSelfProfileInfoWithPublications { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.headerView?.avatarImageView.image = UIImage(data: user.profilePicture ?? Data())
                    self.headerView?.nameLabel.text = user.name
                    self.user = user
                    self.publications = user.publiсations
                    self.profileView?.newsFeedTable.reloadData()
                    CoreDataManager.shared.saveProfileInfo(with: user)
                }
            case .failure(let error):
                print("ошибка получения профиля\(error)")
            }
        }
    }


    private func obtainOnlyProfileInfo() {
        RealTimeDataBaseManager.shared.getProfileInfo { user in
            guard let info = user else {
                print("error obtainOnlyProfileInfo")
                return
            }
            DispatchQueue.main.async {
                self.headerView?.avatarImageView.image = UIImage(data: info.profilePicture ?? Data())
                self.headerView?.nameLabel.text = info.name
                self.user = info
                CoreDataManager.shared.saveProfileInfo(with: info)
            }
        }

    }

}

extension ProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        260
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        520
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        publications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsFeedTableViewCell.reuseIdentifier, for: indexPath) as? NewsFeedTableViewCell
        if let posts = publications {
            cell?.configure(with: posts[indexPath.row])
            return cell ?? UITableViewCell()
        }
        return UITableViewCell()
    }

}

extension ProfileController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return headerView
        case 1:
            return nil
        default:
            return nil
        }
    }

}


extension ProfileController: HeaderViewDelegate {


    func didTappedCreatePublication() {
        let createPublicationVC = CreatePublicationController(user: user ?? nil)
        createPublicationVC.delegate = self
        let navVC = UINavigationController(rootViewController: createPublicationVC)
        present(navVC, animated: true)
    }
    
    func didTappedSignOutButton() {
        let controller = UIAlertController(title: "выход из аккаунта", message: "хотите выйти?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "да", style: .destructive, handler: { [ weak self ] _ in
            guard let strongSelf = self else { return }
            strongSelf.profileViewModel?.signOut()

        }))
        controller.addAction(UIAlertAction(title: "нет", style: .default))
        present(controller, animated: true)
    }
}


extension ProfileController: CreatePublicationControllerDelegate {

    func publicationHasBeenCreated(publication: Publication) {
        publications?.append(publication)
        publications = StorageManager.sortPublicationsByDate(publications: publications ?? [])
        profileView?.newsFeedTable.reloadData()
    }
}
