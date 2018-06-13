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

protocol TableViewAnimatorDataProvider: class {
    func sectionIdentifier(in tableView: UITableView, at index: Int) -> String
    func cellIdentifier(in tableView: UITableView, at indexPath: IndexPath) -> String
    func reloadCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> Void
    func finishedReloadingCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> Void
}
extension TableViewAnimatorDataProvider {
    func reloadCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> Void {}
    func finishedReloadingCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> Void {}
}

class TableViewAnimator {
    
    weak var tableView:UITableView!
    weak var dataProvider:TableViewAnimatorDataProvider!
    
    init(for tableView:UITableView, with provider:TableViewAnimatorDataProvider) {
        self.dataProvider = provider
        self.tableView = tableView
        self.loadListIdentifiers(in: tableView)
    }
    
    var listIdentifiers: AnimatorIdentifiers = ([],[:])
    func loadListIdentifiers(in tableView:UITableView) {
        self.listIdentifiers = ([],[:])
        
        for i in 0 ..< (tableView.dataSource?.numberOfSections?(in: tableView) ?? 0) {
            let sectionIdentifier = self.dataProvider.sectionIdentifier(in: tableView, at: i)
            self.listIdentifiers.section.append(sectionIdentifier)
            self.listIdentifiers.data[sectionIdentifier] = []
            
            for j in 0 ..< (tableView.dataSource?.tableView(tableView, numberOfRowsInSection: i) ?? 0) {
                let identifier = self.dataProvider.cellIdentifier(in: tableView, at: IndexPath(row: j, section: i))
                self.listIdentifiers.data[sectionIdentifier]?.append(identifier)
            }
        }
    }
    func copyListIdentifiers() -> AnimatorIdentifiers {
        var identifiers:AnimatorIdentifiers = ([],[:])
        self.listIdentifiers.section.forEach { identifiers.section.append($0) }
        self.listIdentifiers.data.forEach { identifiers.data[$0] = $1 }
        return identifiers
    }
    
    private var mustReload = false
    func reloadData(with animation:UITableViewRowAnimation = .fade, otherAnimations:@escaping ()->Void = { }, completed:@escaping ()->Void = { }) {
        
        self.mustReload = true
        DispatchQueue.main.async {
            guard self.mustReload else { return }
            self.mustReload = false
            
            let old:AnimatorIdentifiers = self.copyListIdentifiers()
            self.loadListIdentifiers(in: self.tableView)
            let new:AnimatorIdentifiers = self.copyListIdentifiers()
            
            self.tableView.animateChanges(from: old, to: new, animation: .fade, otherAnimations: {
                for indexPath in self.tableView.indexPathsForVisibleRows ?? [] {
                    self.dataProvider.reloadCell(in: self.tableView, forRowAt: indexPath)
                }
                otherAnimations()
            }, completed: {
                for indexPath in self.tableView.indexPathsForVisibleRows ?? [] {
                    self.dataProvider.finishedReloadingCell(in: self.tableView, forRowAt: indexPath)
                }
                completed()
            })
        }
    }
}

extension UITableView {
    
    func animateChanges(from:AnimatorIdentifiers, to:AnimatorIdentifiers, animation:UITableViewRowAnimation = .fade, otherAnimations:@escaping ()->Void = { }, completed:@escaping ()->Void = { }) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completed)
        
        
        self.beginUpdates()
        let reloadSections = self.animateChanges(from: from.section, to: to.section, rowAnimation: animation)
        for sectionIdentifier in reloadSections {
            self.animateChanges(in: to.section.index(of: sectionIdentifier)!, from: from.data[sectionIdentifier]!, to: to.data[sectionIdentifier]!, rowAnimation: animation)
        }
        self.endUpdates()
        
        
        let duration = CATransaction.animationDuration();
        CATransaction.commit();
        
        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction], animations: {
            otherAnimations();
        }) { _ in }
        
    }
    
    @discardableResult
    func animateChanges(from sections_old:[String], to sections_new:[String], rowAnimation:UITableViewRowAnimation) -> [String] {
        
        // REMOVE ITEMS
        var removedItems = Set.init(sections_old); removedItems.subtract(sections_new)
        var removedIndexSet = IndexSet()
        for identifier in removedItems {
            if let index = sections_old.index(of: identifier) {
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
            guard let j = sections_old.index(of: sections_new[i]) else { continue }
            if (i != j) {
                self.moveSection(j, toSection: i)
            }
            reloadItems.append(sections_new[i])
        }
        
        return reloadItems;
    }
    
    @discardableResult
    func animateChanges(in section:Int, from sourceData_old:[String], to sourceData_new:[String], rowAnimation:UITableViewRowAnimation) -> [IndexPath] {
        
        
        // REMOVE ITEMS
        var removedItems = Set.init(sourceData_old); removedItems.subtract(sourceData_new);
        var removedIndexPaths:[IndexPath] = []
        for identifier in removedItems {
            if let index = sourceData_old.index(of: identifier) {
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
            guard let j = sourceData_old.index(of: sourceData_new[i]) else { continue }
            if i != j {
                self.moveRow(at: IndexPath(row: j, section: section), to: IndexPath(row: i, section: section))
            }
            reloadIndexPaths.append(IndexPath(row: i, section: section))
        }
        
        
        return reloadIndexPaths;
    }
    
}
