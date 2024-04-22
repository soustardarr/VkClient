//
//  ProfileController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit
import Combine

class ProfileController: UIViewController {

    

    private var profileView: ProfileView?
    private var headerView: HeaderView?
    private var cancellable: Set<AnyCancellable> = []
    private var profileViewModel: ProfileViewModel?
    private var user: User?


    var array = ["публикация 1","публикация 2"]



    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    private func setup() {
        profileView = ProfileView()
        view = profileView
        profileView?.tableView.delegate = self
        profileView?.tableView.dataSource = self
        profileView?.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        headerView = HeaderView()
        headerView?.delegate = self
        setupProfileInfo()
        profileViewModel = ProfileViewModel()
        obtainProfileFromFirebase()
    }

    private func setupProfileInfo() {
        RealTimeDataBaseManager.shared.$currentUser.sink { user in
            self.headerView?.avatarImageView.image = UIImage(data: user?.profilePicture ?? Data())
            self.headerView?.nameLabel.text = user?.name
        }.store(in: &cancellable)
    }

    private func obtainProfileFromFirebase() {
        profileViewModel?.getProfile(returnUser: { [ weak self ] user in
            DispatchQueue.main.async {
                self?.headerView?.avatarImageView.image = UIImage(data: user?.profilePicture ?? Data())
                self?.headerView?.nameLabel.text = user?.name
                self?.user = user
            }
        })
    }

}

extension ProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        260
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = array[indexPath.row]
        return cell
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
