//
//  RegistrationController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit

class RegistrationController: UIViewController, UINavigationControllerDelegate {

    private var registrationView: RegistrationView?
    weak var registrationControllerCoordinator: RegistrationControllerCoordinator?
    private var viewModel: RegistrationViewModel?


    override func loadView() {
        registrationView = RegistrationView()
        registrationView?.delegate = self
        view = registrationView
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

    }

    private func setup() {
        viewModel = RegistrationViewModel()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePhoto))
        registrationView?.avatarImageView.addGestureRecognizer(gesture)
    }

    @objc private func didTapChangeProfilePhoto() {
        presentAlertCameraOrPhoto()
    }

    private func alertUserLoginError(message: String? = "введите корректную информацию") {
        registrationView?.resignResponder()
        let alertController = UIAlertController(title: "Ошибка!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ок", style: .cancel))
        present(alertController, animated: true)
    }

}

extension RegistrationController: RegistrationViewDelegate {
    
    func doneSignUpButtonTapped() {
        viewModel?.didRegisteredUser(registrationView?.nameTextField.text,
                                     registrationView?.loginTextField.text,
                                     registrationView?.passwordTextField.text,
                                     registrationView?.secondPasswordTextField.text,
                                     registrationView?.avatarImageView.image,
                                     completion: { [ weak self ] boolResult, message in
            DispatchQueue.main.async {
                if boolResult {
                    self?.registrationControllerCoordinator?.dismissToLastVC()
                } else {
                    self?.alertUserLoginError(message: message)
                }
            }
        })
    }
}


extension RegistrationController: UIImagePickerControllerDelegate {

    func presentAlertCameraOrPhoto() {
        let controller = UIAlertController(title: "Фото профиля",
                                           message: "сделать фото или выбрать из галереи",
                                           preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "из галереи", style: .default, handler: { [ weak self ] _ in
            self?.presentPicker()
        }))
        controller.addAction(UIAlertAction(title: "открыть камеру", style: .default, handler: { [ weak self ] _ in
            self?.presentCamera()
        }))
        controller.addAction(UIAlertAction(title: "отмена", style: .cancel))
        present(controller, animated: true)
    }

    func presentPicker() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }

    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let photo = info[.editedImage] as? UIImage {
            picker.dismiss(animated: true)
            registrationView?.avatarImageView.image = photo
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

}
