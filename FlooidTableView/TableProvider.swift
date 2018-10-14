//
//  TableProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 13.06.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

public class TableProvider: NSObject, UITableViewDataSource, UITableViewDelegate, TableViewAnimatorDataProvider {
    
    
    var sections: [SectionProvider] = []
    
    let tableLoader: (TableProvider) -> Void
    
    public init(tableLoader: @escaping (TableProvider) -> Void) {
        self.tableLoader = tableLoader
        super.init()
        self.reload()
    }
    
    public func reload() {
        self.sections.removeAll()
        self.tableLoader(self)
    }

    
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
    
    public func sectionIdentifier(in tableView: UITableView, at index: Int) -> String {
        return self.sections[index].sectionIdentifier(in: tableView)
    }
    
    public func cellIdentifier(in tableView: UITableView, at indexPath: IndexPath) -> String {
        return self.sections[indexPath.section].cellIdentifier(in: tableView, at: indexPath)
    }
    
    public func reloadCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> Void {
        self.sections[indexPath.section].reloadCell(in: tableView, at: indexPath)
    }
    
}

extension SectionProvider {
    public func add(to tableProvider: TableProvider) {
        tableProvider.sections.append(self)
    }
}

extension Sequence where Element == SectionProvider {
    public func add(to tableProvider: TableProvider) {
        for p in self { p.add(to: tableProvider) }
    }
}

extension Sequence where Element: SectionProvider {
    public func add(to tableProvider: TableProvider) {
        for p in self { p.add(to: tableProvider) }
    }
}

extension UITableView {
    public func provided(by provider: TableProvider) {
        self.dataSource = provider
        self.delegate = provider
    }
}
