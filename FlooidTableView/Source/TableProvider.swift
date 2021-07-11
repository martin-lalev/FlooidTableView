//
//  TableProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 22.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import UIKit

public protocol TableProviderScrollDelegate: AnyObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

public class TableProvider: NSObject {
    
    private weak var scrollDelegate: TableProviderScrollDelegate?
    private var sections: [TableSectionProvider] = []
    
    private weak var tableView: UITableView?
    
    public func provide(for tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        self.tableView = tableView
    }
    
    public func assignScrollDelegate(to scrollDelegate: TableProviderScrollDelegate? = nil) {
        self.scrollDelegate = scrollDelegate
    }

    
    
    // MARK: - Private helpers
    
    subscript(_ indexPath: IndexPath) -> TableCellProvider {
        return self[indexPath.section].cellProviders[indexPath.row]
    }
    
    subscript(_ index: Int) -> TableSectionProvider {
        return self.sections[index]
    }

    
    
    // MARK: - Reloading
    
    public func reloadData(sections: [TableSectionProvider], animation: UITableView.RowAnimation = .fade, otherAnimations: @escaping () -> Void = { }, completed: @escaping () -> Void = { }) {
        let old = self.sections.map { ($0.identifier, $0.cellProviders.map { $0.identifier }) }
        self.sections = sections
        let new = self.sections.map { ($0.identifier, $0.cellProviders.map { $0.identifier }) }
        
        guard let tableView = self.tableView else {
            completed()
            return
        }
        
        tableView.update(with: animation, old: old, new: new, animations: {
            for indexPath in tableView.indexPathsForVisibleRows ?? [] {
                if let cell = tableView.cellForRow(at: indexPath) {
                    self[indexPath].setup(cell)
                }
            }
            otherAnimations()
            
        }, completed)
    }
}

extension TableProvider: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self[section].cellProviders.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self[indexPath].reuseIdentifier, for: indexPath as IndexPath)
        self[indexPath].setup(cell)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self[indexPath].height(tableView: tableView)
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self[indexPath].estimatedHeight(tableView: tableView)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < self[indexPath.section].cellProviders.count else { return }
        self[indexPath].willShow(cell)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < self[indexPath.section].cellProviders.count else { return }
        self[indexPath].didHide(cell)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard indexPath.row < self[indexPath.section].cellProviders.count else { continue }
            self[indexPath].prefetch()
        }
    }

    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard indexPath.row < self[indexPath.section].cellProviders.count else { continue }
            self[indexPath].cancelPrefetch()
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
    }
}
