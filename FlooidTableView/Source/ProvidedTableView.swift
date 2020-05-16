//
//  ProvidedTableView.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 16.05.20.
//  Copyright © 2020 Martin Lalev. All rights reserved.
//

import Foundation

open class ProvidedTableView: UITableView {
    
    private(set) public var tableProvider = TableProvider(with: { _ in })
    
    private weak var scrollDelegate: TableProviderScrollDelegate?
    
    public func assignScrollDelegate(to scrollDelegate: TableProviderScrollDelegate) {
        self.scrollDelegate = scrollDelegate
    }
    
    open func register(_ cellTypes: [FlooidTableView.IdentifiableCell.Type] = []) {
        for cellType in cellTypes {
            cellType.register(in: self)
        }
    }
    open func register(_ cellTypes: FlooidTableView.IdentifiableCell.Type ...) {
        self.register(cellTypes)
    }
    open func provide(_ maker: @escaping (ItemsGenerator<TableProvider.Section>) -> Void) {
        self.tableProvider = TableProvider(with: maker)
        self.tableProvider.provide(for: self, scrollDelegate: self)
    }

}

extension ProvidedTableView: TableProviderScrollDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
    }
}
