//
//  TableViewAnimator.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 13.06.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit


typealias AnimatorIdentifiers = (section:[String], data:[String:[String]])

public protocol TableViewAnimatorDataProvider: class {
    func sectionIdentifier(in tableView: UITableView, at index: Int) -> String
    func cellIdentifier(in tableView: UITableView, at indexPath: IndexPath) -> String
    func reloadCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> Void
    func finishedReloadingCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> Void
}
public extension TableViewAnimatorDataProvider {
    func reloadCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> Void {}
    func finishedReloadingCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> Void {}
}
public extension TableViewAnimatorDataProvider {
    internal func identifiers(in tableView:UITableView) -> AnimatorIdentifiers {
        var listIdentifiers: AnimatorIdentifiers = ([],[:])
        
        for i in 0 ..< (tableView.dataSource?.numberOfSections?(in: tableView) ?? 0) {
            let sectionIdentifier = self.sectionIdentifier(in: tableView, at: i)
            listIdentifiers.section.append(sectionIdentifier)
            listIdentifiers.data[sectionIdentifier] = []
            
            for j in 0 ..< (tableView.dataSource?.tableView(tableView, numberOfRowsInSection: i) ?? 0) {
                let identifier = self.cellIdentifier(in: tableView, at: IndexPath(row: j, section: i))
                listIdentifiers.data[sectionIdentifier]?.append(identifier)
            }
        }
        
        return listIdentifiers
    }
}

public class TableViewAnimator {
    
    weak var tableView:UITableView!
    weak var dataProvider:TableViewAnimatorDataProvider!
    var listIdentifiers: AnimatorIdentifiers = ([],[:])
    
    public init(for tableView:UITableView, with provider:TableViewAnimatorDataProvider) {
        self.dataProvider = provider
        self.tableView = tableView
        self.listIdentifiers = self.dataProvider.identifiers(in: tableView)
    }
    
    private var mustReload = false
    private func reloadData(_ completed: @escaping (AnimatorIdentifiers, AnimatorIdentifiers) -> Void) {
        self.mustReload = true
        DispatchQueue.main.async {
            guard self.mustReload else { return }
            self.mustReload = false
            
            let old = self.listIdentifiers
            self.listIdentifiers = self.dataProvider.identifiers(in: self.tableView)
            let new = self.listIdentifiers
            
            completed(old, new)
        }
    }
    public func reloadData(with animation: UITableView.RowAnimation = .fade, otherAnimations: @escaping () -> Void = { }, completed: @escaping () -> Void = { }) {
        self.reloadData { (old, new) in
            
            self.tableView.update(changes: {
                let reloadSections = self.tableView.animateSectionsChanges(from: old.section, to: new.section, rowAnimation: animation)
                for sectionIdentifier in reloadSections {
                    self.tableView.animateCellsChanges(in:new.section.firstIndex(of: sectionIdentifier)!, from: old.data[sectionIdentifier]!, to: new.data[sectionIdentifier]!, rowAnimation: animation)
                }
                
            }, animations: {
                for indexPath in self.tableView.indexPathsForVisibleRows ?? [] {
                    self.dataProvider.reloadCell(in: self.tableView, forRowAt: indexPath)
                }
                otherAnimations()
                
            }) {
                for indexPath in self.tableView.indexPathsForVisibleRows ?? [] {
                    self.dataProvider.finishedReloadingCell(in: self.tableView, forRowAt: indexPath)
                }
                completed()
            }
        }
    }
}





extension UITableView {
    func update(changes: () -> Void, animations: @escaping () -> Void, _ completed: @escaping () -> Void = { }) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completed)
        
        self.beginUpdates()
        changes()
        self.endUpdates()
        
        let duration = CATransaction.animationDuration();
        CATransaction.commit();
        
        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction], animations: {
            animations()
        })
        self.beginUpdates()
        self.endUpdates()

    }
}

extension UITableView {

    @discardableResult
    func animateSectionsChanges(from sections_old:[String], to sections_new:[String], rowAnimation:UITableView.RowAnimation) -> [String] {
        
        // REMOVE ITEMS
        var removedItems = Set.init(sections_old); removedItems.subtract(sections_new)
        var removedIndexSet = IndexSet()
        for identifier in removedItems {
            if let index = sections_old.firstIndex(of: identifier) {
                removedIndexSet.insert(index)
            }
        }
        self.deleteSections(removedIndexSet, with: rowAnimation)
        
        
        // ADD ITEMS
        var addedItems = Set.init(sections_new); addedItems.subtract(sections_old)
        var addedIndexSet = IndexSet()
        for i in 0 ..< sections_new.count {
            if addedItems.contains(sections_new[i]) {
                addedIndexSet.insert(i)
            }
        }
        self.insertSections(addedIndexSet, with: rowAnimation)
        
        
        
        // MOVE ITEMS
        
        var reloadItems:[String] = [];
        for i in 0 ..< sections_new.count {
            guard !addedItems.contains(sections_new[i]) else { continue }
            guard let j = sections_old.firstIndex(of: sections_new[i]) else { continue }
            if (i != j) {
                self.moveSection(j, toSection: i)
            }
            reloadItems.append(sections_new[i])
        }
        
        return reloadItems;
    }
    
    func animateCellsChanges(in section:Int, from sourceData_old:[String], to sourceData_new:[String], rowAnimation:UITableView.RowAnimation) {
        
        
        // REMOVE ITEMS
        var removedItems = Set.init(sourceData_old); removedItems.subtract(sourceData_new);
        var removedIndexPaths:[IndexPath] = []
        for identifier in removedItems {
            if let index = sourceData_old.firstIndex(of: identifier) {
                removedIndexPaths.append(IndexPath(row: index, section: section))
            }
        }
        self.deleteRows(at: removedIndexPaths, with: rowAnimation)
        
        
        // ADD ITEMS
        var addedItems = Set.init(sourceData_new); addedItems.subtract(sourceData_old)
        var addedIndexPaths:[IndexPath] = []
        for i in 0 ..< sourceData_new.count {
            if addedItems.contains(sourceData_new[i]) {
                addedIndexPaths.append(IndexPath(row: i, section: section))
            }
        }
        self.insertRows(at: addedIndexPaths, with: rowAnimation)
        
        
        // MOVE ITEMS
        var reloadIndexPaths:[IndexPath] = [];
        for i in 0 ..< sourceData_new.count {
            guard !addedItems.contains(sourceData_new[i]) else { continue }
            guard let j = sourceData_old.firstIndex(of: sourceData_new[i]) else { continue }
            if i != j {
                self.moveRow(at: IndexPath(row: j, section: section), to: IndexPath(row: i, section: section))
            } else {
                reloadIndexPaths.append(IndexPath(row: i, section: section))
            }
        }
//        self.reloadRows(at: reloadIndexPaths, with: rowAnimation)
    }
    
}
