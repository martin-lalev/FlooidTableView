//
//  FlooidTableViewSection.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 27.08.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

public struct FlooidTableViewSection: SectionProvider {
    
    let sectionIdentifier: String
    public internal(set) var provider: CelledSectionProvider
    
    public init(in tableView: UITableView, _ sectionIdentifier:String, with provider: CelledSectionProvider) {
        self.sectionIdentifier = sectionIdentifier
        self.provider = provider
        self.registerCells(in: tableView)
    }
    
    public mutating func updateProvider(to provider: CelledSectionProvider) {
        self.provider = provider
    }
    
    public func registerCells(in tableView: UITableView) -> Void {
        self.provider.registerCells(in: tableView)
    }
    
    public func numberOfRows(in tableView: UITableView) -> Int {
        return self.provider.numberOfRows
    }
    
    public func cellForRow(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        return self.provider.cellProvider(at: indexPath.row).dequeue(in:tableView, at:indexPath)
    }
    
    public func heightForCell(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        return self.provider.cellProvider(at: indexPath.row).height(in:tableView, at:indexPath)
    }
    
    public func reloadCell(in tableView: UITableView, at indexPath: IndexPath) -> Void {
        self.provider.cellProvider(at: indexPath.row).reload(in:tableView, at:indexPath)
    }
    
    public func sectionIdentifier(in tableView: UITableView) -> String {
        return self.sectionIdentifier
    }
    
    public func cellIdentifier(in tableView: UITableView, at indexPath: IndexPath) -> String {
        return self.provider.cellProvider(at: indexPath.row).identifier(in:tableView, at:indexPath)
    }
    
}
