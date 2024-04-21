//
//  HeaderView.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 18.04.2024.
//

import UIKit

protocol HeaderViewDelegate: AnyObject {
    func didTappedSignOutButton()
}

class HeaderView: UITableViewHeaderFooterView {

    weak var delegate: HeaderViewDelegate?

    var backgroundViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.image = .kitty
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()

    var nameLabel: UILabel = {
        var nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()

    var exitButton: UIImageView = {
        let exitButton = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.link])
        let settingsImage = UIImage(systemName: "rectangle.portrait.and.arrow.forward", withConfiguration: colorConfig)
        exitButton.image = settingsImage
        exitButton.isUserInteractionEnabled = true
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        return exitButton
    }()

    var addPublicationButton: UIImageView = {
        let addPublicationButton = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.link])
        let settingsImage = UIImage(systemName: "pencil.tip.crop.circle.badge.plus", withConfiguration: colorConfig)
        addPublicationButton.image = settingsImage
        addPublicationButton.isUserInteractionEnabled = true
        addPublicationButton.translatesAutoresizingMaskIntoConstraints = false
        return addPublicationButton
    }()

    var friendScreenButton: UIButton = {
        let button = UIButton()
        button.setTitle("Друзья", for: .normal)
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var followersScreenButton: UIButton = {
        let button = UIButton()
        button.setTitle("Подписчики", for: .normal)
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()


    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
        addGesture()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addGesture() {
        let exitGesture = UITapGestureRecognizer(target: self, action: #selector(handleExitGesture))
        exitButton.addGestureRecognizer(exitGesture)
    }
    @objc private func handleExitGesture() {
        delegate?.didTappedSignOutButton()
    }

    private func setupUI() {
        contentView.addSubview(backgroundViewContainer)
        backgroundViewContainer.addSubview(nameLabel)
        backgroundViewContainer.addSubview(avatarImageView)
        backgroundViewContainer.addSubview(exitButton)
        stackView.addArrangedSubview(friendScreenButton)
        stackView.addArrangedSubview(followersScreenButton)
        backgroundViewContainer.addSubview(stackView)
        backgroundViewContainer.addSubview(addPublicationButton)

        NSLayoutConstraint.activate([
                backgroundViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                backgroundViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                backgroundViewContainer.topAnchor.constraint(equalTo: topAnchor),
                backgroundViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

                avatarImageView.leadingAnchor.constraint(equalTo: backgroundViewContainer.leadingAnchor, constant: 30),
                avatarImageView.topAnchor.constraint(equalTo: backgroundViewContainer.safeAreaLayoutGuide.topAnchor),
                avatarImageView.widthAnchor.constraint(equalToConstant: 150),
                avatarImageView.heightAnchor.constraint(equalToConstant: 150),

                nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
                nameLabel.centerXAnchor.constraint(equalTo: backgroundViewContainer.leadingAnchor, constant: 105),

                exitButton.trailingAnchor.constraint(equalTo: backgroundViewContainer.trailingAnchor, constant: -30),
                exitButton.topAnchor.constraint(equalTo: backgroundViewContainer.safeAreaLayoutGuide.topAnchor),
                exitButton.heightAnchor.constraint(equalToConstant: 30),
                exitButton.widthAnchor.constraint(equalToConstant: 30),

                addPublicationButton.trailingAnchor.constraint(equalTo: exitButton.leadingAnchor, constant: -15),
                addPublicationButton.topAnchor.constraint(equalTo: backgroundViewContainer.safeAreaLayoutGuide.topAnchor),
                addPublicationButton.heightAnchor.constraint(equalToConstant: 33),
                addPublicationButton.widthAnchor.constraint(equalToConstant: 33),

                stackView.centerXAnchor.constraint(equalTo: backgroundViewContainer.centerXAnchor),
                stackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
                stackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 30)

            ])

    }
}
