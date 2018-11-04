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

public class TableViewAnimator {
    
    weak var tableView:UITableView!
    weak var dataProvider:TableViewAnimatorDataProvider!
    
    public init(for tableView:UITableView, with provider:TableViewAnimatorDataProvider) {
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
    public func reloadData(with animation:UITableView.RowAnimation = .fade, otherAnimations:@escaping ()->Void = { }, completed:@escaping ()->Void = { }) {
        
        self.mustReload = true
        DispatchQueue.main.async {
            guard self.mustReload else { return }
            self.mustReload = false
            
            let old:AnimatorIdentifiers = self.copyListIdentifiers()
            self.loadListIdentifiers(in: self.tableView)
            let new:AnimatorIdentifiers = self.copyListIdentifiers()
            
            self.tableView.animateChanges(from: old, to: new, animation: .fade, reloadCells: {
                for indexPath in $0 {
                    self.dataProvider.reloadCell(in: self.tableView, forRowAt: indexPath)
                }
            }, otherAnimations: otherAnimations, completed: {
                for indexPath in self.tableView.indexPathsForVisibleRows ?? [] {
                    self.dataProvider.finishedReloadingCell(in: self.tableView, forRowAt: indexPath)
                }
                completed()
            })
        }
    }
}

extension UITableView {
    
    func animateChanges(from:AnimatorIdentifiers, to:AnimatorIdentifiers, animation:UITableView.RowAnimation = .fade, reloadCells: @escaping ([IndexPath]) -> Void = { _ in }, otherAnimations:@escaping ()->Void = { }, completed:@escaping ()->Void = { }) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completed)
        
        
        self.beginUpdates()
        let reloadSections = self.animateChanges(from: from.section, to: to.section, rowAnimation: animation)
        var reloadIndexPaths: [IndexPath] = []
        for sectionIdentifier in reloadSections {
            reloadIndexPaths.append(contentsOf: self.animateChanges(in: to.section.index(of: sectionIdentifier)!, from: from.data[sectionIdentifier]!, to: to.data[sectionIdentifier]!, rowAnimation: animation))
        }
        reloadCells(reloadIndexPaths)
        self.endUpdates()
        
        
        let duration = CATransaction.animationDuration();
        CATransaction.commit();
        
        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction], animations: {
            otherAnimations();
        }) { _ in }
        
    }
    
//    @discardableResult
//    func animateChanges(from sections_old:[String], to sections_new:[String], rowAnimation:UITableView.RowAnimation) -> [String] {
//
//        let operations = diff(sections_old, sections_new)
//
//        var reloadItems:[String] = [];
//
//        for operation in operations {
//            switch operation {
//            case .delete(let index):
//                self.deleteSections(IndexSet.init(integer: index), with: rowAnimation)
//            case .insert(let index):
//                self.insertSections(IndexSet.init(integer: index), with: rowAnimation)
//            case .move(let from, let to):
//                self.moveSection(from, toSection: to)
//            case .update(let index):
//                reloadItems.append(sections_new[index])
//            }
//        }
//
//        return reloadItems;
//    }
//
//    @discardableResult
//    func animateChanges(in section:Int, from sourceData_old:[String], to sourceData_new:[String], rowAnimation:UITableView.RowAnimation) -> [IndexPath] {
//
//        let operations = diff(sourceData_old, sourceData_new)
//
//        var reloadIndexPaths:[IndexPath] = []
//
//        for operation in operations {
//            switch operation {
//            case .delete(let index):
//                self.deleteRows(at: [IndexPath(row: index, section: section)], with: rowAnimation)
//            case .insert(let index):
//                self.insertRows(at: [IndexPath(row: index, section: section)], with: rowAnimation)
//            case .move(let from, let to):
//                self.moveRow(at: IndexPath(row: from, section: section), to: IndexPath(row: to, section: section))
//            case .update(let index):
//                reloadIndexPaths.append(IndexPath(row: index, section: section))
//            }
//        }
//
//        return reloadIndexPaths;
//    }
    
    @discardableResult
    func animateChanges(from sections_old:[String], to sections_new:[String], rowAnimation:UITableView.RowAnimation) -> [String] {
        
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
    func animateChanges(in section:Int, from sourceData_old:[String], to sourceData_new:[String], rowAnimation:UITableView.RowAnimation) -> [IndexPath] {
        
        
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
