//
//  TableViewDataSource.swift
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

public class TableViewDataSource: NSObject {
    
    public weak var scrollDelegate: TableProviderScrollDelegate?
    var sections: [SectionProvider] = []
    
    let tableLoader: (TableViewProviderGenerator) -> Void
    
    weak var tableView:UITableView!
    
    public init(for tableView: UITableView, scrollDelegate: TableProviderScrollDelegate?, tableLoader: @escaping (TableViewProviderGenerator) -> Void) {
        self.tableView = tableView
        self.scrollDelegate = scrollDelegate
        self.tableLoader = tableLoader
        super.init()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    func updateTable() {
        self.sections = TableViewProviderGenerator.make(self.tableLoader).sectionProviders
    }
    
    
    
    // MARK: - Reloading
    
    private var mustReload = false
    private func reloadData(_ completed: @escaping ([(String, [String])], [(String, [String])]) -> Void) {
        self.mustReload = true
        DispatchQueue.main.async {
            guard self.mustReload else { return }
            self.mustReload = false
            
            let old = self.sections.map { ($0.sectionIdentifier, $0.cellProviders.map { $0.identifier }) }
            self.updateTable()
            let new = self.sections.map { ($0.sectionIdentifier, $0.cellProviders.map { $0.identifier }) }
            
            completed(old, new)
        }
    }
    
    public func reloadData(animation: UITableView.RowAnimation = .fade, otherAnimations: @escaping () -> Void = { }, completed: @escaping () -> Void = { }) {
        guard animation != .none else {
            self.updateTable()
            self.tableView.reloadData()
            completed()
            return
        }
        self.reloadData { (old, new) in
            
            self.tableView.update(changes: {
                let reloadSections = self.tableView.animateSectionsChanges(from: old.map { $0.0 }, to: new.map { $0.0 }, rowAnimation: animation)
                for sectionIdentifier in reloadSections {
                    let index = new.firstIndex(where: { $0.0 == sectionIdentifier })!
                    let from = old.first(where: { $0.0 == sectionIdentifier })!.1
                    let to = new.first(where: { $0.0 == sectionIdentifier })!.1
                    self.tableView.animateCellsChanges(in: index, from: from, to: to, rowAnimation: animation)
                }
                
            }, animations: {
                for indexPath in self.tableView.indexPathsForVisibleRows ?? [] {
                    self.sections[indexPath.section].reloadCell(in: self.tableView, at: indexPath)
                }
                otherAnimations()
                
            }) {
                completed()
            }
        }
    }
}

extension TableViewDataSource: UITableViewDataSource, UITableViewDelegate {
    
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
