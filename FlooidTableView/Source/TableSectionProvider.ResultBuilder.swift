//
//  SectionProvider.ResultBuilder.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 11/07/2021.
//  Copyright © 2021 Martin Lalev. All rights reserved.
//

import UIKit

public protocol TableViewSectionArrayConvertible {
    func items() -> [TableSectionProvider]
}
extension TableSectionProvider: TableViewSectionArrayConvertible {
    public func items() -> [TableSectionProvider] { [self] }
}
extension Array: TableViewSectionArrayConvertible where Element == TableSectionProvider {
    public func items() -> [TableSectionProvider] { self }
}

@resultBuilder
public struct TableViewSectionsArrayBuilder {
    
    public static func buildBlock(_ components: TableViewSectionArrayConvertible ...) -> TableViewSectionArrayConvertible { components.flatMap { $0.items() } }
    
    public static func buildIf(_ component: TableViewSectionArrayConvertible?) -> TableViewSectionArrayConvertible { component ?? [TableSectionProvider]() }
    
    public static func buildEither(first: TableViewSectionArrayConvertible) -> TableViewSectionArrayConvertible { first }
    
    public static func buildEither(second: TableViewSectionArrayConvertible) -> TableViewSectionArrayConvertible { second }
    
}

public extension TableProvider {
    func reloadData(@TableViewSectionsArrayBuilder with maker: @escaping () -> TableViewSectionArrayConvertible, animation: UITableView.RowAnimation = .fade, otherAnimations: @escaping () -> Void = { }, completed: @escaping () -> Void = { }) {
        self.reloadData(sections: maker().items(), animation: animation, otherAnimations: otherAnimations, completed: completed)
    }
}
