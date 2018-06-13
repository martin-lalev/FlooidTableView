//
//  CellProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 13.06.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

protocol CellProvider {
    
    func dequeue(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    
    func height(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat
    
    func identifier(in tableView: UITableView, at indexPath: IndexPath) -> String
    
    func reload(in tableView: UITableView, at indexPath: IndexPath) -> Void
    
}



protocol CelledSectionProvider {
    
    var sectionIdentifier: String { get }
    
    var numberOfRows: Int { get }
    
    func cellProvider(at row:Int) -> CellProvider
    
    func registerCells(in tableView: UITableView) -> Void
    
}

extension CelledSectionProvider {
    
    public func sectionProvider(in tableView:UITableView) -> CelledSection {
        return CelledSection(in: tableView, self.sectionIdentifier, with: self)
    }
    
}

struct CelledSection: SectionProvider {
    
    let sectionIdentifier:String
    let provider:CelledSectionProvider
    
    init(in tableView: UITableView, _ sectionIdentifier:String, with provider:CelledSectionProvider) {
        self.sectionIdentifier = sectionIdentifier
        self.provider = provider
        self.registerCells(in: tableView)
    }
    
    func registerCells(in tableView: UITableView) -> Void {
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
    
    func reloadCell(in tableView: UITableView, at indexPath: IndexPath) -> Void {
        self.provider.cellProvider(at: indexPath.row).reload(in:tableView, at:indexPath)
    }
    
    func sectionIdentifier(in tableView: UITableView) -> String {
        return self.sectionIdentifier
    }
    
    func cellIdentifier(in tableView: UITableView, at indexPath: IndexPath) -> String {
        return self.provider.cellProvider(at: indexPath.row).identifier(in:tableView, at:indexPath)
    }
    
}
