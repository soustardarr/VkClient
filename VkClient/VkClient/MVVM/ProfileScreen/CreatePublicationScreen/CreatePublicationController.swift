//
//  CreatePublicationController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 21.04.2024.
//

import UIKit

class CreatePublicationController: UIViewController, UINavigationControllerDelegate {

    private var createPublicationView: CreatePublicationView?
    private var viewModel: CreatePublicationViewModel?
    private var user: User?
    init(user: User? = nil) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }


    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
    }

    private func setup() {
        createPublicationView = CreatePublicationView()
        view = createPublicationView
        createPublicationView?.delegate = self
        viewModel = CreatePublicationViewModel()
    }

    private func setupNavigationBar() {
        let rightBarButton = UIBarButtonItem(title: "Опубликовать",
                                             style: .done,
                                             target: self,
                                             action: #selector(didToPublishTapped))
        rightBarButton.tintColor = .black
        navigationController?.navigationBar.topItem?.rightBarButtonItem = rightBarButton

        let dissmisAction = UIAction { _ in self.dismiss(animated: true)}
        let leftBarButton = UIBarButtonItem(systemItem: .close, primaryAction: dissmisAction)
        navigationController?.navigationBar.topItem?.leftBarButtonItem = leftBarButton
    }

    @objc private func didToPublishTapped() {
        guard let user = user else {
            print("self user отсутсвует")
            return
        }
        let text = createPublicationView?.textView.text
        let image = createPublicationView?.imagePublication.image

        guard text != nil || image != nil else {
            print("контента нет для публиакации")
            return
        }
        viewModel?.sendPublicationToFirebase(text ?? "", image ?? UIImage(), user)
        // ДОБАВЛЕНИЕ В ТАБЛИЦУ ПРОФИЛЯ
        dismiss(animated: true)

    }

}


extension CreatePublicationController: CreatePublicationViewDelegate {

    func didTappedSetImage() {
        presentAlertCameraOrPhoto()
    }
    

}

extension CreatePublicationController: UIImagePickerControllerDelegate {

    func presentAlertCameraOrPhoto() {
        let controller = UIAlertController(title: "Выбрать фото",
                                           message: "сделать фото или выбрать из галереи",
                                           preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "из галереи", style: .default, handler: { [ weak self ] _ in
            self?.createPublicationView?.setImagePublication.isHidden = true
            self?.presentPicker()
        }))
        controller.addAction(UIAlertAction(title: "открыть камеру", style: .default, handler: { [ weak self ] _ in
            self?.createPublicationView?.setImagePublication.isHidden = true
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
            self.createPublicationView?.addImageLayout()
            self.createPublicationView?.imagePublication.image = photo
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

}
