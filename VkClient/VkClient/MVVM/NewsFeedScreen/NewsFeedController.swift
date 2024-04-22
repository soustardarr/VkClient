//
//  ViewController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit
import Combine

class NewsFeedController: UIViewController {


    private var newsFeedTableView: NewsFeedTableView?
    private var viewModel: NewsFeedViewModel?
    private var publications: [Publication]?
    private var cancellable: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupDataBindings()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    private func setup() {
        newsFeedTableView = NewsFeedTableView()
        view = newsFeedTableView
        viewModel = NewsFeedViewModel()
        newsFeedTableView?.newsFeedTable.delegate = self
        newsFeedTableView?.newsFeedTable.dataSource = self
        newsFeedTableView?.newsFeedTable.register(NewsFeedTableViewCell.self, forCellReuseIdentifier: NewsFeedTableViewCell.reuseIdentifier)
        newsFeedTableView?.newsFeedTable.reloadData()
        viewModel?.getNewsFromFriends()
    }

    private func setupDataBindings() {
        viewModel?.$publications.sink(receiveValue: { [ weak self ] posts in
            self?.publications = posts
            DispatchQueue.main.async {
                self?.newsFeedTableView?.newsFeedTable.reloadData()
            }
        }).store(in: &cancellable)
    }
}

extension NewsFeedController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        510
    }
}


extension NewsFeedController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        publications?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsFeedTableViewCell.reuseIdentifier, for: indexPath) as? NewsFeedTableViewCell
        if let posts = publications {
            cell?.configure(with: posts[indexPath.row])
            return cell ?? UITableViewCell()
        }
        return UITableViewCell()
    }
}

