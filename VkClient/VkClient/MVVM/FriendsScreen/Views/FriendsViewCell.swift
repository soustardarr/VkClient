//
//  FriendsViewCell.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import UIKit

class FriendsViewCell: UITableViewCell {

    var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        let config = UIImage.SymbolConfiguration(paletteColors: [.black, .white])
        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        avatarImageView.layer.cornerRadius = 15
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()

    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "user"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func config(_ friend: Friend) {
        DispatchQueue.main.async {
            self.avatarImageView.image = friend.avatar
            self.nameLabel.textColor = .black
            self.nameLabel.text = friend.name
        }
    }

    func config(with user: User) {
        DispatchQueue.main.async {
            self.nameLabel.textColor = .white
            self.nameLabel.text = user.name
        }
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            avatarImageView.widthAnchor.constraint(equalToConstant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: 30),

            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 30)
        ])

    }


}
