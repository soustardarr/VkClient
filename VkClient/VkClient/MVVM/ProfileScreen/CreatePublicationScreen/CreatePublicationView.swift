//
//  CreatePublicationView.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 21.04.2024.
//

import UIKit

protocol CreatePublicationViewDelegate: AnyObject {
    func didTappedSetImage()
}


class CreatePublicationView: UIView {

    weak var delegate: CreatePublicationViewDelegate?

    var textView: UITextView = {
        let textView = UITextView()
        textView.borderStyle = .none
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.autocorrectionType = .no
        textView.keyboardType = .default
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что у вас нового?"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var imagePublication: UIImageView = {
        let imagePublication = UIImageView()
        imagePublication.translatesAutoresizingMaskIntoConstraints = false
        return imagePublication
    }()

    var setImagePublication: UIImageView = {
        let setImagePublication = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.black])
        let image = UIImage(systemName: "photo.badge.plus.fill", withConfiguration: colorConfig)
        setImagePublication.image = image
        setImagePublication.isUserInteractionEnabled = true
        setImagePublication.translatesAutoresizingMaskIntoConstraints = false
        return setImagePublication
    }()


    var setImagePublicationBottomConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        textView.delegate = self
        setup()
        addGesture()
        addObserversOnKeyboard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addGesture() {
        let setImageGesture = UITapGestureRecognizer(target: self, action: #selector(handleSetImageGesture))
        setImagePublication.addGestureRecognizer(setImageGesture)
    }

    @objc private func handleSetImageGesture() {
        self.delegate?.didTappedSetImage()
    }

    private func addObserversOnKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let distance = keyboardSize.height + 1
            updateSetImagePublicationBottomConstraint(constant: -distance)
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        updateSetImagePublicationBottomConstraint(constant: -1)
    }

    private func updateSetImagePublicationBottomConstraint(constant: CGFloat) {
        setImagePublicationBottomConstraint?.constant = constant
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    func addImageLayout() {
        addSubview(imagePublication)
        NSLayoutConstraint.activate([
            imagePublication.topAnchor.constraint(equalTo: textView.bottomAnchor),
            imagePublication.heightAnchor.constraint(equalToConstant: 350),
            imagePublication.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 0),
        ])
    }

    private func setup() {
        backgroundColor = .white
        addSubview(textView)
        addSubview(placeholderLabel)
        addSubview(setImagePublication)

        setImagePublicationBottomConstraint = setImagePublication.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24)
        setImagePublicationBottomConstraint?.isActive = true
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            textView.heightAnchor.constraint(equalToConstant: 50),

            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            placeholderLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 23),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

            setImagePublication.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            setImagePublicationBottomConstraint!,
            setImagePublication.widthAnchor.constraint(equalToConstant: 60),
            setImagePublication.heightAnchor.constraint(equalToConstant: 50)

        ])
    }
}


extension CreatePublicationView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        textView.sizeToFit()
        placeholderLabel.isHidden = !textView.text.isEmpty

        let contentSize = textView.contentSize.height
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = contentSize
            }
        }

        self.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = textView.frame.origin.y + contentSize + 15
            }
        }
        setNeedsLayout()
    }


}
