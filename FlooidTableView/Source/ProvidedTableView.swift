//
//  ProvidedTableView.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 16.05.20.
//  Copyright © 2020 Martin Lalev. All rights reserved.
//

import Foundation

open class ProvidedTableView: UITableView {
    
    public let tableProvider = TableProvider()
    
    private weak var scrollDelegate: TableProviderScrollDelegate?
    
    public func assignScrollDelegate(to scrollDelegate: TableProviderScrollDelegate) {
        self.scrollDelegate = scrollDelegate
    }
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.provide()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.provide()
    }
    
    open func register(_ cellTypes: [FlooidTableView.IdentifiableCell.Type] = []) {
        for cellType in cellTypes {
            cellType.register(in: self)
        }
    }
    open func register(_ cellTypes: FlooidTableView.IdentifiableCell.Type ...) {
        self.register(cellTypes)
    }
    private func provide() {
        self.tableProvider.provide(for: self, scrollDelegate: self)
    }

}

extension ProvidedTableView: TableProviderScrollDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
    }
}
