//
//  SectionProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 13.06.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

public protocol SectionProvider {
    
    func numberOfRows(in tableView: UITableView) -> Int
    
    func cellForRow(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    
    func heightForCell(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat
    
    func sectionIdentifier(in tableView: UITableView) -> String
    
    func cellIdentifier(in tableView: UITableView, at indexPath: IndexPath) -> String
    
    func reloadCell(in tableView: UITableView, at indexPath: IndexPath) -> Void
    
    func registerCells(in tableView: UITableView) -> Void
    
}
