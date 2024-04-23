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
        handThumbsupButton.isUserInteractionEnabled = true
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

    lazy var countLikes: UILabel = {
        let countLikes = UILabel()
        countLikes.text = "0"
        countLikes.textColor = .black
        countLikes.font = UIFont.systemFont(ofSize: 20)
        countLikes.translatesAutoresizingMaskIntoConstraints = false
        return countLikes
    }()

    func configure(with post: Publication) {
        self.post = post
        avatarView.image = post.avatarImage
        nameLabel.text = post.name
        image.image = UIImage(data: post.publiactionImageData ?? Data())
        date.text = post.date
        text.text = post.text
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let safeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
        if post.like?.count != nil {
            countLikes.text = String(post.like?.count ?? 0)
        }
        if post.like?.likedByCurrentUser == true {
            let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.red])
            let handThumbsupImage = UIImage(systemName: "hand.thumbsup.fill", withConfiguration: colorConfig)
            handThumbsupButton.image = handThumbsupImage
        }
    }
    var post: Publication?


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func addGesture() {
        let gestureLike = UITapGestureRecognizer(target: self, action: #selector(didTapLike))
        handThumbsupButton.addGestureRecognizer(gestureLike)
    }

    @objc private func didTapLike() {
        guard var post = post else { return }
        post.like?.toggleLiked()

        let colorConfig: UIImage.SymbolConfiguration
        if post.like?.likedByCurrentUser ?? false {
            colorConfig = UIImage.SymbolConfiguration(paletteColors: [.red])
            var cnt = Int(countLikes.text ?? "0") ?? 0
            cnt += 1
            countLikes.text = String(cnt)
        } else {
            colorConfig = UIImage.SymbolConfiguration(paletteColors: [.black])
            var cnt = Int(countLikes.text ?? "1") ?? 1
            cnt -= 1
            countLikes.text = String(cnt)
        }
        let handThumbsupImage = UIImage(systemName: post.like?.likedByCurrentUser ?? false ? "hand.thumbsup.fill" : "hand.thumbsup", withConfiguration: colorConfig)
        handThumbsupButton.image = handThumbsupImage

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
        contentView.addSubview(countLikes)

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

            countLikes.leadingAnchor.constraint(equalTo: handThumbsupButton.trailingAnchor, constant: 7),
            countLikes.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 11),

            paperplaneButton.heightAnchor.constraint(equalToConstant: 25),
            paperplaneButton.widthAnchor.constraint(equalToConstant: 25),
            paperplaneButton.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10),
            paperplaneButton.leadingAnchor.constraint(equalTo: handThumbsupButton.trailingAnchor, constant: 25),

        ])
    }
}
