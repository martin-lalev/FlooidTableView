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
    
    public struct Section {
        public let identifier: String
        public let cellProviders: [CellProvider]
    }

    private weak var scrollDelegate: TableProviderScrollDelegate?
    private var sections: [Section] = []
    private var sectionsLoader: () -> [Section]
    
    private weak var tableView: UITableView?
    
    public init(with sectionsLoader: @autoclosure @escaping () -> [Section]) {
        self.sectionsLoader = sectionsLoader
        super.init()
    }
    public func provide(for tableView: UITableView, scrollDelegate: TableProviderScrollDelegate? = nil) {
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView = tableView
        self.scrollDelegate = scrollDelegate
        self.sections = self.sectionsLoader()
    }
    
    
    
    // MARK: - Private helpers
    
    subscript(_ indexPath: IndexPath) -> CellProvider {
        return self[indexPath.section].cellProviders[indexPath.row]
    }
    
    subscript(_ index: Int) -> Section {
        return self.sections[index]
    }

    
    
    // MARK: - Reloading
    
    public func reloadData(animation: UITableView.RowAnimation = .fade, _ completed: @escaping () -> Void = { }) {
        let old = self.sections.map { ($0.identifier, $0.cellProviders.map { $0.identifier }) }
        self.sections = self.sectionsLoader()
        let new = self.sections.map { ($0.identifier, $0.cellProviders.map { $0.identifier }) }
        
        if let tableView = self.tableView {
            tableView.update(with: animation, old: old, new: new, completed)
        } else {
            completed()
        }
    }
}

extension TableProvider: UITableViewDataSource, UITableViewDelegate {
    
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


    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
    }
}
