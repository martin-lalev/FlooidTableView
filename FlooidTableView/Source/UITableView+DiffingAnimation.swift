//
//  UITableView+Animation.swift
//  FacebookCore
//
//  Created by Martin Lalev on 22.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    private func update(changes: () -> Void, animations: @escaping () -> Void, _ completed: @escaping () -> Void = { }) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completed)
        
        self.beginUpdates()
        changes()
        self.endUpdates()
        
        let duration = CATransaction.animationDuration();
        CATransaction.commit();
        
        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction], animations: animations)
        self.beginUpdates()
        self.endUpdates()
        
    }
    
    func update(with animation: UITableView.RowAnimation, old: [DiffableTableSection], new: [DiffableTableSection], animations: @escaping () -> Void, _ completed: @escaping () -> Void = { }) {
        guard old != new else { return completed() }
        
        self.update(changes: {
            
            let sectionsFrom = old.map { $0.identifier }
            let sectionsTo = new.map { $0.identifier }

            self.applyToSections(Changes.make(from: sectionsFrom, to: sectionsTo), with: animation)
            
            for sectionIdentifier in Set(sectionsTo).intersection(sectionsFrom) {
                let sectionIndex = new.firstIndex(where: { $0.identifier == sectionIdentifier })!
                let cellsFrom = old.first(where: { $0.identifier == sectionIdentifier })!.cellIdentifiers
                let cellsTo = new.first(where: { $0.identifier == sectionIdentifier })!.cellIdentifiers
                
                self.applyToCells(Changes.make(from: cellsFrom, to: cellsTo), at: sectionIndex, with: animation)
            }
        }, animations: animations, completed)
    }
    
    private func applyToSections(_ changes: Changes, with animation: UITableView.RowAnimation) {
        self.deleteSections(IndexSet(changes.deleted), with: animation)
        self.insertSections(IndexSet(changes.inserted), with: animation)
        for move in changes.moved { self.moveSection(move.from, toSection: move.to) }
    }
    
    private func applyToCells(_ changes: Changes, at sectionIndex: Int, with animation: UITableView.RowAnimation) {
        self.deleteRows(at: changes.deleted.map { IndexPath(row: $0, section: sectionIndex) }, with: animation)
        self.insertRows(at: changes.inserted.map { IndexPath(row: $0, section: sectionIndex) }, with: animation)
        for move in changes.moved { self.moveRow(at: IndexPath(row: move.from, section: sectionIndex), to: IndexPath(row: move.to, section: sectionIndex)) }
    }

}

struct DiffableTableSection: Equatable {
    let identifier: String
    let cellIdentifiers: [String]
    let heightIdentifiers: [String]
}

struct Changes {
    
    let deleted: [Int]
    let inserted: [Int]
    let moved: [(from: Int, to: Int)]
    
    static func make(from old:[String], to new:[String]) -> Changes {
        let removedItems = Set(old).subtracting(new)
        let addedItems = Set(new).subtracting(old)

        return Changes(
            deleted: removedItems.compactMap {
                guard let index = old.firstIndex(of: $0) else { return nil }
                return index
            },
            inserted: new.enumerated().compactMap {
                guard addedItems.contains(new[$0.offset]) else { return nil }
                return $0.offset
            },
            moved: new.enumerated().compactMap {
                guard !addedItems.contains(new[$0.offset]) else { return nil }
                guard let j = old.firstIndex(of: new[$0.offset]) else { return nil }
                guard $0.offset != j else { return nil }
                return (from: j, to: $0.offset)
            }
        )
    }
}
