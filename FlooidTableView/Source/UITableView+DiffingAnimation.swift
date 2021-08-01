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
    
    func update(with animation: UITableView.RowAnimation, changes: TableChanges, animations: @escaping () -> Void, _ completed: @escaping () -> Void = { }) {
        guard !changes.isEmpty else {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction], animations: animations)
            self.beginUpdates()
            self.endUpdates()
            return completed()
        }
        self.update(changes: {
            self.applyToSections(changes.sectionChanges, with: animation)
            
            for (sectionIndex, changes) in changes.rowChanges {
                self.applyToCells(changes, at: sectionIndex, with: animation)
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

struct Changes {
    
    let deleted: [Int]
    let inserted: [Int]
    let moved: [(from: Int, to: Int)]
    
    static func make<H: Hashable>(from old:[H], to new:[H]) -> Changes {
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
    
    var isEmpty: Bool {
        return deleted.isEmpty && inserted.isEmpty && moved.isEmpty
    }
}

struct TableChanges {
    let sectionChanges: Changes
    let rowChanges: [(Int, Changes)]
    
    var isEmpty: Bool {
        return self.sectionChanges.isEmpty && self.rowChanges.reduce(into: true, { $0 = $0 && $1.1.isEmpty })
    }
}

extension TableChanges {
    static func make<HS: Hashable, HC: Hashable>(old: [(HS, [HC])], new: [(HS, [HC])]) -> TableChanges {

        let sectionsFrom = old.map { $0.0 }
        let sectionsTo = new.map { $0.0 }

        let sectionChanges = Changes.make(from: sectionsFrom, to: sectionsTo)
        
        let rowChanges = Set(sectionsTo).intersection(sectionsFrom).map { sectionIdentifier -> (Int, Changes) in
            let sectionIndex = new.firstIndex(where: { $0.0 == sectionIdentifier })!
            let cellsFrom = old.first(where: { $0.0 == sectionIdentifier })!.1
            let cellsTo = new.first(where: { $0.0 == sectionIdentifier })!.1
            return (sectionIndex, Changes.make(from: cellsFrom, to: cellsTo))
        }
        
        return .init(sectionChanges: sectionChanges, rowChanges: rowChanges)
    }
}
