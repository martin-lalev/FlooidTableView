//
//  TableProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 22.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit


public protocol TableProviderScrollDelegate: class {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

public class TableProvider: NSObject {
    
    public weak var scrollDelegate: TableProviderScrollDelegate?
    var sections: [SectionProvider] = []
    
    var tableLoader: (TableViewProviderGenerator) -> Void
    
    weak var tableView: UITableView!
    
    public init(tableLoader: @escaping (TableViewProviderGenerator) -> Void) {
        self.tableLoader = tableLoader
        super.init()
    }
    public func provide(for tableView: UITableView, scrollDelegate: TableProviderScrollDelegate? = nil) {
        self.tableView = tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.scrollDelegate = scrollDelegate
        self.sections = TableViewProviderGenerator.make(self.tableLoader).sectionProviders
    }
    
    
    
    // MARK: - Reloading
    
    private var mustReload = false
    public func reloadData(animation: UITableView.RowAnimation = .fade, otherAnimations: @escaping () -> Void = { }, completed: @escaping () -> Void = { }) {
        self.mustReload = true
        DispatchQueue.main.async {
            guard self.mustReload else { return }
            self.mustReload = false
            
            let old = self.sections.map { ($0.sectionIdentifier, $0.cellProviders.map { $0.identifier }) }
            self.sections = TableViewProviderGenerator.make(self.tableLoader).sectionProviders
            let new = self.sections.map { ($0.sectionIdentifier, $0.cellProviders.map { $0.identifier }) }
            
            self.tableView.update(with: animation, old: old, new: new, animations: {
                for indexPath in self.tableView.indexPathsForVisibleRows ?? [] {
                    self.sections[indexPath.section].reloadCell(in: self.tableView, at: indexPath)
                }
                otherAnimations()
                
            }, completed)
        }
    }
}

extension TableProvider: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].numberOfRows(in: tableView)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cellForRow(in: tableView, at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.sections[indexPath.section].heightForCell(in: tableView, at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.sections[indexPath.section].estimatedHeightForCell(in: tableView, at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.sections[indexPath.section].willShow(cell, in: tableView, at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.sections[indexPath.section].didHide(cell, in: tableView, at: indexPath)
    }


    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
    }
}
