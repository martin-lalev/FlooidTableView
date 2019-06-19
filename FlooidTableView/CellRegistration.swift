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
    static func register(in tableView: UITableView)
}



public protocol CodebasedCellView: IdentifiableTableViewCell {
    static var registerableClass: AnyClass? { get }
}

public extension CodebasedCellView {
    static var registerableClass: AnyClass? { return self }
    static func register(in tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: self.reuseIdentifier)
    }
}



public protocol XibbedCellView: IdentifiableTableViewCell {
    static var xibName: String { get }
    static var bundle: Bundle? { get }
}
public extension XibbedCellView {
    static var bundle: Bundle? { return .main }
    static func register(in tableView: UITableView) {
        tableView.register(UINib(nibName: self.xibName, bundle: self.bundle), forCellReuseIdentifier: self.reuseIdentifier)
    }
}
