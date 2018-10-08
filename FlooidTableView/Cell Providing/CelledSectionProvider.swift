//
//  CelledSectionProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 27.08.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

public protocol CelledSectionProvider {
    
    var sectionIdentifier: String { get }
    
    var numberOfRows: Int { get }
    
    func cellProvider(at row:Int) -> CellProvider
    
    func registerCells(in tableView: UITableView) -> Void
    
}

extension CelledSectionProvider {
    
    public func sectionProvider(in tableView:UITableView) -> FlooidTableViewSection {
        return FlooidTableViewSection(in: tableView, self.sectionIdentifier, with: self)
    }
    
}

public protocol FlooidTableViewCelledProviderDelegate: TableProviderDelegate {
    func celledSectionProvider(in tableView:UITableView, at index:Int) -> CelledSectionProvider
}

extension FlooidTableViewCelledProviderDelegate {
    public func sectionProvider(in tableView:UITableView, at index:Int) -> SectionProvider {
        return self.celledSectionProvider(in: tableView, at: index).sectionProvider(in: tableView)
    }
}
