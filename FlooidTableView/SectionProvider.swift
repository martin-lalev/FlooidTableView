//
//  SectionProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 13.06.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

public struct SectionProvider {
    
    public let sectionIdentifier: String
    public let cellProviders: [CellProvider]
    
    public init(_ identifier: String, _ maker: (SectionProviderGenerator) -> Void) {
        self.sectionIdentifier = identifier
        self.cellProviders = SectionProviderGenerator.make(maker).cellProviders
    }
    
    
    public func numberOfRows(in tableView: UITableView) -> Int {
        return self.cellProviders.count
    }
    
    public func cellForRow(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        return self.cellProviders[indexPath.row].dequeue(in:tableView, at:indexPath)
    }
    
    public func heightForCell(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        return self.cellProviders[indexPath.row].height(in:tableView, at:indexPath)
    }
    
    public func estimatedHeightForCell(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        return self.cellProviders[indexPath.row].estimatedHeight(in:tableView, at:indexPath)
    }
    
    public func reloadCell(in tableView: UITableView, at indexPath: IndexPath) -> Void {
        self.cellProviders[indexPath.row].reload(in:tableView, at:indexPath)
    }
    
    public func sectionIdentifier(in tableView: UITableView) -> String {
        return self.sectionIdentifier
    }
    
    public func cellIdentifier(in tableView: UITableView, at indexPath: IndexPath) -> String {
        return self.cellProviders[indexPath.row].identifier(in:tableView, at:indexPath)
    }
    
    public func willShow(_ cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) -> Void {
        guard indexPath.row < self.cellProviders.count else { return }
        self.cellProviders[indexPath.row].willShow(cell, in: tableView, at: indexPath)
    }
    
    public func didHide(_ cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) -> Void {
        guard indexPath.row < self.cellProviders.count else { return }
        self.cellProviders[indexPath.row].didHide(cell, in: tableView, at: indexPath)
    }
}
