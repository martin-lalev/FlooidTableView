//
//  TableProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 13.06.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

public protocol TableProviderDelegate: class {
    func sectionProvider(in tableView:UITableView, at index:Int) -> SectionProvider
    func numberOfSections(in tableView: UITableView) -> Int
}

public class TableProvider: NSObject {
    weak var delegate: TableProviderDelegate!
    public init(for tableView:UITableView, delegate:TableProviderDelegate) {
        self.delegate = delegate
        
        super.init()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
}

public extension TableProvider: UITableViewDataSource , UITableViewDelegate, TableViewAnimatorDataProvider {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.delegate.numberOfSections(in:tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.delegate.sectionProvider(in: tableView, at: section).numberOfRows(in: tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.delegate.sectionProvider(in: tableView, at: indexPath.section).cellForRow(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.delegate.sectionProvider(in: tableView, at: indexPath.section).heightForCell(in: tableView, at: indexPath)
    }
    
    func sectionIdentifier(in tableView: UITableView, at index: Int) -> String {
        return self.delegate.sectionProvider(in: tableView, at: index).sectionIdentifier(in: tableView)
    }
    
    func cellIdentifier(in tableView: UITableView, at indexPath: IndexPath) -> String {
        return self.delegate.sectionProvider(in: tableView, at: indexPath.section).cellIdentifier(in: tableView, at: indexPath)
    }
    
    func reloadCell(in tableView: UITableView, forRowAt indexPath: IndexPath) -> Void {
        self.delegate.sectionProvider(in: tableView, at: indexPath.section).reloadCell(in: tableView, at: indexPath)
    }
    
}
