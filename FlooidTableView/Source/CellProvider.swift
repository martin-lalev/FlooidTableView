//
//  CellProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 13.06.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

public protocol IdentifiableCell: UITableViewCell {
    static var reuseIdentifier: String { get }
    static func register(in view: UITableView)
}

public protocol CellProvider {
    
    var identifier: String { get }
    var reuseIdentifier: String { get }

    func height(tableView: UITableView) -> CGFloat
    func estimatedHeight(tableView: UITableView) -> CGFloat

    func setup(_ cell: UITableViewCell)
    func willShow(_ cell: UITableViewCell)
    func didHide(_ cell: UITableViewCell)
    
    func prefetch()
    func cancelPrefetch()
    
}

extension CellProvider {
    
    public func willShow(_ cell: UITableViewCell) {
    }
    
    public func didHide(_ cell: UITableViewCell) {
    }
    
    public func estimatedHeight(tableView: UITableView) -> CGFloat {
        return self.height(tableView: tableView)
    }
    
    public func prefetch() {
    }
    
    public func cancelPrefetch() {
    }

}
