//
//  NewsFeedTableViewCell.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import UIKit

class NewsFeedTableViewCell: UITableViewCell {

    lazy var avatarView: UIImageView = {
        let avatarView = UIImageView()
        avatarView.image = UIImage.kitty
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.layer.cornerRadius = 25
        avatarView.layer.masksToBounds = true
        return avatarView
    }()

    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "name"
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()

    lazy var image: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .kitty
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var handThumbsupButton: UIImageView = {
        let handThumbsupButton = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.black])
        let handThumbsupImage = UIImage(systemName: "hand.thumbsup", withConfiguration: colorConfig)
        handThumbsupButton.image = handThumbsupImage
        handThumbsupButton.translatesAutoresizingMaskIntoConstraints = false
        return handThumbsupButton
    }()

    lazy var paperplaneButton: UIImageView = {
        let paperplaneButton = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.black])
        let paperplaneButtonImage = UIImage(systemName: "paperplane", withConfiguration: colorConfig)
        paperplaneButton.image = paperplaneButtonImage
        paperplaneButton.translatesAutoresizingMaskIntoConstraints = false
        return paperplaneButton
    }()

    lazy var date: UILabel = {
        let date = UILabel()
        date.text = "12.01.2024"
        date.textColor = .lightGray
        date.font = UIFont.systemFont(ofSize: 10)
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()

    lazy var text: UILabel = {
        let text = UILabel()
        text.text = "Text"
        text.textColor = .black
        text.font = UIFont.systemFont(ofSize: 14)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()

    func configure(with post: Publication) {
        avatarView.image = post.avatarImage
        nameLabel.text = post.name
        image.image = UIImage(data: post.publiactionImageData ?? Data())
        date.text = post.date
        text.text = post.text
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        contentView.addSubview(text)
        contentView.addSubview(handThumbsupButton)
        contentView.addSubview(paperplaneButton)
        contentView.addSubview(date)

        NSLayoutConstraint.activate([

            avatarView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            avatarView.widthAnchor.constraint(equalToConstant: 50),

            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 15),

            date.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 15),
            date.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),

            image.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 10),
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            image.heightAnchor.constraint(equalToConstant: 350),
            image.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 0),

            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            text.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 15),


            handThumbsupButton.heightAnchor.constraint(equalToConstant: 25),
            handThumbsupButton.widthAnchor.constraint(equalToConstant: 25),
            handThumbsupButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            handThumbsupButton.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10),

            paperplaneButton.heightAnchor.constraint(equalToConstant: 25),
            paperplaneButton.widthAnchor.constraint(equalToConstant: 25),
            paperplaneButton.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10),
            paperplaneButton.leadingAnchor.constraint(equalTo: handThumbsupButton.trailingAnchor, constant: 15),

        ])
    }
}
