//
//  CellProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 13.06.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

public protocol CellProvider {
    
    func dequeue(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    
    func height(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat
    
    func identifier(in tableView: UITableView, at indexPath: IndexPath) -> String
    
    func reload(in tableView: UITableView, at indexPath: IndexPath) -> Void
    
}

extension UITableViewCell {
    public static func register(in tableView:UITableView) {
        tableView.register(self, forCellReuseIdentifier: self.description())
    }
}

public class AnyCellProvider<CellType: UITableViewCell>: CellProvider {
    
    let setup: (CellType)->Void
    let height: CGFloat
    let identifier: String
    
    public init(identifier: String, height: CGFloat, setup: @escaping (CellType)->Void) {
        self.identifier = identifier
        self.height = height
        self.setup = setup
    }
    
    public func dequeue(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellType.description(), for: indexPath as IndexPath) as! CellType
        self.setup(cell)
        return cell
    }
    
    public func reload(in tableView: UITableView, at indexPath: IndexPath) -> Void {
        guard let cell = tableView.cellForRow(at: indexPath) as? CellType else { return }
        self.setup(cell)
    }
    
    public func height(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        return self.height
    }
    
    public func identifier(in tableView: UITableView, at indexPath: IndexPath) -> String {
        return self.identifier
    }
    
}
