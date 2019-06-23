//
//  UITableView+Animation.swift
//  FacebookCore
//
//  Created by Martin Lalev on 22.06.19.
//

import Foundation
import UIKit

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
