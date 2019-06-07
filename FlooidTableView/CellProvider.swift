//
//  CellProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 13.06.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    public static func register(in tableView:UITableView) {
        tableView.register(self, forCellReuseIdentifier: self.description())
    }
}

public protocol CellProvider {
    
    var identifier: String { get }
    var cellIdentifier: String { get }

    func height(tableView: UITableView) -> CGFloat
    func estimatedHeight(tableView: UITableView) -> CGFloat

    func setup(_ cell: UITableViewCell)
    func willShow(_ cell: UITableViewCell)
    func didHide(_ cell: UITableViewCell)
}

extension CellProvider {
    public func willShow(_ cell: UITableViewCell) { }
    public func didHide(_ cell: UITableViewCell) { }
    public func estimatedHeight(tableView: UITableView) -> CGFloat {
        return self.height(tableView: tableView)
    }
}

extension CellProvider {
    
    public func dequeue(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath as IndexPath)
        self.setup(cell)
        return cell
    }
    
    public func reload(in tableView: UITableView, at indexPath: IndexPath) -> Void {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        self.setup(cell)
    }
    
    public func height(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        return self.height(tableView: tableView)
    }
    
    public func estimatedHeight(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        return self.estimatedHeight(tableView: tableView)
    }
    
    public func identifier(in tableView: UITableView, at indexPath: IndexPath) -> String {
        return self.identifier
    }
    
    public func willShow(_ cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) -> Void {
        self.willShow(cell)
    }
    
    public func didHide(_ cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) -> Void {
        self.didHide(cell)
    }

}





// Any Cell Provider
public protocol SpecificCellProvider: CellProvider {
    associatedtype CellType: UITableViewCell
    
    func setup(_ cell: CellType)
    func willShow(_ cell: CellType)
    func didHide(_ cell: CellType)
}
public extension SpecificCellProvider {
    var cellIdentifier: String { return CellType.description() }
    func setup(_ cell: UITableViewCell) {
        guard let cell = cell as? CellType else { return }
        self.setup(cell)
    }
    func willShow(_ cell: UITableViewCell) {
        guard let cell = cell as? CellType else { return }
        self.willShow(cell)
    }
    func didHide(_ cell: UITableViewCell) {
        guard let cell = cell as? CellType else { return }
        self.didHide(cell)
    }
}
public extension SpecificCellProvider {
    func willShow(_ cell: CellType) {}
    func didHide(_ cell: CellType) {}
}



// StandardCellProvder
public class AnyCellProvider<CellType: UITableViewCell>: SpecificCellProvider {
    
    let setup: (CellType)->Void
    let willShow: (CellType)->Void
    let didHide: (CellType)->Void
    let height: (UITableView) -> CGFloat
    let heightEstimation: ((UITableView) -> CGFloat)?
    public let identifier: String
    
    public init(identifier: String, height: @escaping (UITableView) -> CGFloat, heightEstimation: ((UITableView) -> CGFloat)? = nil, willShow: @escaping (CellType)->Void = { _ in }, didHide: @escaping (CellType)->Void = { _ in }, setup: @escaping (CellType)->Void) {
        self.identifier = identifier
        self.height = height
        self.heightEstimation = heightEstimation
        self.setup = setup
        self.willShow = willShow
        self.didHide = didHide
    }
    public convenience init(identifier: String, height: CGFloat, heightEstimation: ((UITableView) -> CGFloat)? = nil, willShow: @escaping (CellType)->Void = { _ in }, didHide: @escaping (CellType)->Void = { _ in }, setup: @escaping (CellType)->Void) {
        self.init(identifier: identifier, height: { _ in height }, heightEstimation: heightEstimation, willShow: willShow, didHide: didHide, setup: setup)
    }
    
    public func height(tableView: UITableView) -> CGFloat {
        return self.height(tableView)
    }
    public func estimatedHeight(tableView: UITableView) -> CGFloat {
        return self.heightEstimation?(tableView) ?? self.height(tableView)
    }
    public func setup(_ cell: CellType) {
        return self.setup(cell)
    }
    public func willShow(_ cell: CellType) {
        return self.willShow(cell)
    }
    public func didHide(_ cell: CellType) {
        return self.didHide(cell)
    }

}
