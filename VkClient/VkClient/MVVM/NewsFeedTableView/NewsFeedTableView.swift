//
//  NewsFeedTableView.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import UIKit

class NewsFeedTableView: UIView {

    var newsFeedTable: UITableView = {
        let newsFeedTableView = UITableView()
        newsFeedTableView.backgroundColor = .white
        newsFeedTableView.separatorStyle = .singleLine
        newsFeedTableView.translatesAutoresizingMaskIntoConstraints = false
        return newsFeedTableView
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(newsFeedTable)

        NSLayoutConstraint.activate([
            newsFeedTable.leadingAnchor.constraint(equalTo: leadingAnchor),
            newsFeedTable.trailingAnchor.constraint(equalTo: trailingAnchor),
            newsFeedTable.bottomAnchor.constraint(equalTo: bottomAnchor),
            newsFeedTable.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        ])
    }

}
