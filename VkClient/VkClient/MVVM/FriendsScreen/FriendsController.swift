//
//  FriendsController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit
import Combine

class FriendsController: UIViewController {

    private var friendsView: FriendsView?
    private var friendsViewModel: FriendsViewModel?

    var results: [User]!
    var cancellable: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = false
        setupNavigationBar()
    }

    private func setup() {
        friendsView = FriendsView()
        view = friendsView
        friendsViewModel = FriendsViewModel()
        friendsView?.friendsTableView.delegate = self
        friendsView?.friendsTableView.dataSource = self
        friendsView?.friendsTableView.register(FriendsViewCell.self, forCellReuseIdentifier: FriendsViewCell.reuseIdentifier)
        setupDataBindings()

    }

    private func setupDataBindings() {
        friendsViewModel?.$results
            .sink(receiveValue: { [ weak self ] users in
                self?.results = users
                self?.friendsView?.friendsTableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem(block: {
                    self?.friendsView?.hud.dismiss()
                }))
            })
            .store(in: &cancellable)
    }


    private func setupNavigationBar() {
        friendsView?.searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = friendsView?.searchBar
        let rightBarButton = UIBarButtonItem(title: "отмена",
                                             style: .done,
                                             target: self,
                                             action: #selector(didCancelTapped))
        rightBarButton.tintColor = .black
        navigationController?.navigationBar.topItem?.rightBarButtonItem = rightBarButton
    }

    @objc func didCancelTapped() {
        friendsView?.searchBar.resignFirstResponder()
        results.removeAll()
        friendsViewModel?.results?.removeAll()
        friendsViewModel?.users.removeAll()
        friendsViewModel?.hasFetched = false
        friendsView?.friendsTableView.reloadData()
    }

}

extension FriendsController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        searchBar.resignFirstResponder()
        friendsViewModel?.results?.removeAll()
        friendsView?.hud.show(in: view, animated: true)
        friendsViewModel?.searchUsers(text: text)
        friendsView?.hud.dismiss()
        updateUI()
        friendsView?.friendsTableView.reloadData()
    }

    func updateUI() {
        if friendsViewModel!.results?.isEmpty == true {
            friendsView?.noFriendsLabel.isHidden = false
            friendsView?.friendsTableView.isHidden = true
        } else {
            friendsView?.noFriendsLabel.isHidden = true
            friendsView?.friendsTableView.isHidden = false
            friendsView?.friendsTableView.reloadData()
        }
    }

}


extension FriendsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.results != nil {
            return self.results.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendsViewCell.reuseIdentifier, for: indexPath) as? FriendsViewCell
        if self.results != nil {

            let user = User(name: self.results[indexPath.row].name,
                                  email: self.results[indexPath.row].email)
            StorageManager.shared.downloadImage(user.profilePictureFileName) { result in
                switch result {
                case.success(let imageData):
                    let user = Friend(name: self.results[indexPath.row].name,
                                      avatar: UIImage(data: imageData))
                    print(user)
                    cell?.config(user)
                case .failure(let error):
                    print("ошибка установки фото \(error)")
                }
            }
            return cell ?? UITableViewCell()
        }
        return UITableViewCell()
    }
    

}

extension FriendsController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? FriendsViewCell {
            guard let avatarImage = cell.avatarImageView.image else { return }
            let vc = PeopleProfileController(avatarimage: avatarImage, currentUser: results[indexPath.row], indexPath: indexPath)
            self.present(vc, animated: true)
        }
    }

}
