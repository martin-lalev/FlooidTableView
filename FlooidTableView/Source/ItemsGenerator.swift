//
//  ItemsGenerator.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 22.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Cells Array Builder

public protocol TableViewCellArrayConvertible {
    func items() -> [CellProvider]
}
extension CellProvider: TableViewCellArrayConvertible {
    public func items() -> [CellProvider] { [self] }
}
extension Array: TableViewCellArrayConvertible where Element: CellProvider {
    public func items() -> [CellProvider] { self }
}

@resultBuilder
public struct TableViewCellsArrayBuilder {

    public static func buildBlock(_ components: TableViewCellArrayConvertible ...) -> TableViewCellArrayConvertible { components.flatMap { $0.items() } }

    public static func buildIf(_ component: TableViewCellArrayConvertible?) -> TableViewCellArrayConvertible { component ?? [CellProvider]() }

    public static func buildEither(first: TableViewCellArrayConvertible) -> TableViewCellArrayConvertible { first }

    public static func buildEither(second: TableViewCellArrayConvertible) -> TableViewCellArrayConvertible { second }

}

public func Section(_ identifier: String, @TableViewCellsArrayBuilder _ viewBuilder: () -> TableViewCellArrayConvertible) -> TableProvider.Section {
    return TableProvider.Section(identifier: identifier, cellProviders: viewBuilder().items())
}

// MARK: - Sections Array Builder

public protocol TableViewSectionArrayConvertible {
    func items() -> [TableProvider.Section]
}
extension TableProvider.Section: TableViewSectionArrayConvertible {
    public func items() -> [TableProvider.Section] { [self] }
}
extension Array: TableViewSectionArrayConvertible where Element == TableProvider.Section {
    public func items() -> [TableProvider.Section] { self }
}

@resultBuilder
public struct TableViewSectionsArrayBuilder {
    
    public static func buildBlock(_ components: TableViewSectionArrayConvertible ...) -> TableViewSectionArrayConvertible { components.flatMap { $0.items() } }
    
    public static func buildIf(_ component: TableViewSectionArrayConvertible?) -> TableViewSectionArrayConvertible { component ?? [TableProvider.Section]() }
    
    public static func buildEither(first: TableViewSectionArrayConvertible) -> TableViewSectionArrayConvertible { first }
    
    public static func buildEither(second: TableViewSectionArrayConvertible) -> TableViewSectionArrayConvertible { second }
    
}

public extension TableProvider {
    func reloadData(@TableViewSectionsArrayBuilder with maker: @escaping () -> TableViewSectionArrayConvertible, animation: UITableView.RowAnimation = .fade, otherAnimations: @escaping () -> Void = { }, completed: @escaping () -> Void = { }) {
        self.reloadData(sections: maker().items(), animation: animation, otherAnimations: otherAnimations, completed: completed)
    }
}
