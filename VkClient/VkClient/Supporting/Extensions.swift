//
//  Extensions.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import Foundation
import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
