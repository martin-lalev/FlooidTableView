//
//  CellRegistration.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 8.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

public protocol IdentifiableTableViewCell: UITableViewCell {
    static var reuseIdentifier: String { get }
}

public extension IdentifiableTableViewCell {
    static func register(in tableView:UITableView) {
        tableView.register(self, forCellReuseIdentifier: self.reuseIdentifier)
    }
}

public protocol XibbedCellView {
    static var xibName: String { get }
    static var bundle: Bundle? { get }
}
public extension XibbedCellView {
    static var bundle: Bundle? { return .main }
}

public extension XibbedCellView where Self: IdentifiableTableViewCell {
    static func register(in tableView:UITableView) {
        tableView.register(UINib(nibName: self.xibName, bundle: self.bundle), forCellReuseIdentifier: self.reuseIdentifier)
    }
}
