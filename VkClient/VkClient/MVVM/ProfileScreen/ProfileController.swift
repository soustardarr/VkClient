//
//  ProfileController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit

class ProfileController: UIViewController {

    

    private var profileView: ProfileView?
    private var headerView: HeaderView?

    var array = ["публикация 1","публикация 2"]



    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

    }
    private func setup() {
        profileView = ProfileView()
        view = profileView
        profileView?.tableView.delegate = self
        profileView?.tableView.dataSource = self
        profileView?.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        headerView = HeaderView()
    }

}

extension ProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        260
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = array[indexPath.row]
        return cell
    }

}

extension ProfileController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return headerView
        case 1:
            return nil
        default:
            return nil
        }
    }

}
