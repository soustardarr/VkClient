//
//  FriendsView.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import UIKit
import JGProgressHUD


class FriendsView: UIView {

    var hud = JGProgressHUD(style: .dark)

    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "поиск по никнейму..."
        searchBar.searchTextField.textColor = .black
        searchBar.barStyle = .default
        searchBar.backgroundColor = .white
        searchBar.barTintColor = .white
        return searchBar
    }()

    var friendsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 30)
        label.text = "друзья"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    var friendsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isHidden = true
        return tableView
    }()

    var noFriendsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 30)
        label.text = "друзей нет"
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
//        addSubview(friendsLabel)
        addSubview(friendsTableView)
//        addSubview(noFriendsLabel)
        NSLayoutConstraint.activate([

//            friendsLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: 25),
//            friendsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
//
//            noFriendsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            noFriendsLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
//
            friendsTableView.topAnchor.constraint(equalTo: topAnchor),
            friendsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            friendsTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            friendsTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }




}
