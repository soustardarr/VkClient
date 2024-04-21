//
//  PeopleProfileView.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import UIKit

protocol PeopleProfileViewDelegate: AnyObject {
    func didTappedFriendButton()
}

class PeopleProfileView: UIView {
    
    weak var delegate: PeopleProfileViewDelegate?

    var imageMinus: UIImageView = {
        var imageMinus = UIImageView(image: .minus)
        imageMinus.translatesAutoresizingMaskIntoConstraints = false
        return imageMinus
    }()

    var buttonSettings: UIImageView = {
        let buttonSettings = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.gray])
        let settingsImage = UIImage(systemName: "gearshape.fill", withConfiguration: colorConfig)
        buttonSettings.image = settingsImage
        buttonSettings.isUserInteractionEnabled = true
        buttonSettings.translatesAutoresizingMaskIntoConstraints = false
        return buttonSettings
    }()

    var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.image = .kitty
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()

    var nameLabel: UILabel = {
        var nameLabel = UILabel()
        nameLabel.text = "Some Name"
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()

    lazy var friendButton: UIButton = {
        let button = UIButton()
        button.setTitle("подписаться", for: .normal)
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal)
        let action = UIAction { _ in self.delegate?.didTappedFriendButton() }
        button.addAction(action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var buttonMessage: UIImageView = {
        let buttonMessage = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.gray])
        let messageImage = UIImage(systemName: "message.badge.circle.fill", withConfiguration: colorConfig)
        buttonMessage.image = messageImage
        buttonMessage.isUserInteractionEnabled = true
        buttonMessage.translatesAutoresizingMaskIntoConstraints = false
        return buttonMessage
    }()

    var peopleNewsFeed: UILabel = {
        var peopleNewsFeed = UILabel()
        peopleNewsFeed.text = "публикации: "
        peopleNewsFeed.font = UIFont.systemFont(ofSize: 22)
        peopleNewsFeed.textColor = .gray
        peopleNewsFeed.translatesAutoresizingMaskIntoConstraints = false
        return peopleNewsFeed
    }()

    var friendsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .green
        tableView.isHidden = true
        tableView.separatorStyle = .none
        return tableView
    }()

    var label: UILabel = {
        var label = UILabel()
        label.text = "посты"
        label.font = UIFont.systemFont(ofSize: 22)
        label.textColor = .red
        label.textAlignment = .center
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

        addSubview(imageMinus)
        addSubview(buttonSettings)
        addSubview(nameLabel)
        addSubview(avatarImageView)
        addSubview(buttonMessage)
        addSubview(friendButton)
        addSubview(peopleNewsFeed)
        addSubview(friendsTableView)
        addSubview(label)
        NSLayoutConstraint.activate([
            imageMinus.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageMinus.topAnchor.constraint(equalTo: topAnchor, constant: 10),

            buttonSettings.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonSettings.topAnchor.constraint(equalTo: imageMinus.bottomAnchor, constant: 10),
            buttonSettings.widthAnchor.constraint(equalToConstant: 35),
            buttonSettings.heightAnchor.constraint(equalToConstant: 35),

            nameLabel.topAnchor.constraint(equalTo: buttonSettings.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            avatarImageView.topAnchor.constraint(equalTo: buttonSettings.topAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 150),
            avatarImageView.heightAnchor.constraint(equalToConstant: 150),

            buttonMessage.leadingAnchor.constraint(equalTo: buttonSettings.trailingAnchor, constant: 20),
            buttonMessage.topAnchor.constraint(equalTo: imageMinus.bottomAnchor, constant: 10),
            buttonMessage.widthAnchor.constraint(equalToConstant: 36),
            buttonMessage.heightAnchor.constraint(equalToConstant: 36),

            friendButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            friendButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            friendButton.heightAnchor.constraint(equalToConstant: 35),
            friendButton.widthAnchor.constraint(equalToConstant: 120),

            peopleNewsFeed.topAnchor.constraint(equalTo: friendButton.bottomAnchor, constant: 30),
            peopleNewsFeed.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            friendsTableView.topAnchor.constraint(equalTo: peopleNewsFeed.bottomAnchor, constant: 10),
            friendsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            friendsTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            friendsTableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),

        ])

    }

}
