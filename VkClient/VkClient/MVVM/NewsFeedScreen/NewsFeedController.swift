//
//  ViewController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit

class NewsFeedController: UIViewController {


    private var newsFeedTableView: NewsFeedTableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    private func setup() {
        newsFeedTableView = NewsFeedTableView()
        view = newsFeedTableView
        newsFeedTableView?.newsFeedTable.delegate = self
        newsFeedTableView?.newsFeedTable.dataSource = self
        newsFeedTableView?.newsFeedTable.register(NewsFeedTableViewCell.self, forCellReuseIdentifier: NewsFeedTableViewCell.reuseIdentifier)
        newsFeedTableView?.newsFeedTable.reloadData()

    }
}

extension NewsFeedController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsFeedTableViewCell.reuseIdentifier, for: indexPath) as? NewsFeedTableViewCell
        guard let validCell = cell else {
            return UITableView.automaticDimension
        }
        validCell.contentView.layoutIfNeeded()
        let height = validCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        return height
    }
}


extension NewsFeedController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsFeedTableViewCell.reuseIdentifier, for: indexPath) as? NewsFeedTableViewCell
        return cell ?? UITableViewCell()
    }
}

