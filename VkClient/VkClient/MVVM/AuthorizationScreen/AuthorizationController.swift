//
//  AuthorizationController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit

class AuthorizationController: UIViewController {

    weak var authorizationControllerCoordinator: AuthorizationControllerCoordinator?
    private var authView: AuthorizationView?
    private var authorizationViewModel: AuthorizationViewModel?

    override func loadView() {
        authView = AuthorizationView()
        authView?.delegate = self
        view = authView
    }


    override func viewDidLoad() {
        super.viewDidLoad()
//        CoreDataManager.shared.deleteAllUsers()
        setup()
    }

    private func setup() {
        authorizationViewModel = AuthorizationViewModel()
    }

    private func alertUserLoginError() {
        authView?.resignResponders()
        let alertController = UIAlertController(title: "Ошибка!", message: "проверьте правильность email или пароля", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ок", style: .cancel))
        present(alertController, animated: true)
    }

}

extension AuthorizationController: AuthorizationViewDelegate {
    func didLoginButtonTapped(email: String, password: String) {
        authorizationViewModel?.didLoginAccount(email, password, completion: { [ weak self ] boolResult in
            if boolResult {
                self?.authorizationControllerCoordinator?.runTabBar()
            } else {
                self?.alertUserLoginError()
            }
        })
    }
    
    

    
    func didTapRegister() {
        authorizationControllerCoordinator?.runRegistration()
    }
    

}
