//
//  TableCellProvider.ResultBuilder.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 11/07/2021.
//  Copyright © 2021 Martin Lalev. All rights reserved.
//

import UIKit

public protocol TableViewCellArrayConvertible {
    func items() -> [TableCellProvider]
}
extension TableCellProvider: TableViewCellArrayConvertible {
    public func items() -> [TableCellProvider] { [self] }
}
extension Array: TableViewCellArrayConvertible where Element == TableCellProvider {
    public func items() -> [TableCellProvider] { self }
}

@resultBuilder
public struct TableViewCellsArrayBuilder {

    public static func buildBlock(_ components: TableViewCellArrayConvertible ...) -> TableViewCellArrayConvertible { components.flatMap { $0.items() } }

    public static func buildIf(_ component: TableViewCellArrayConvertible?) -> TableViewCellArrayConvertible { component ?? [TableCellProvider]() }

    public static func buildEither(first: TableViewCellArrayConvertible) -> TableViewCellArrayConvertible { first }

    public static func buildEither(second: TableViewCellArrayConvertible) -> TableViewCellArrayConvertible { second }

}

public extension TableSectionProvider {
    init(_ identifier: String, @TableViewCellsArrayBuilder _ viewBuilder: () -> TableViewCellArrayConvertible) {
        self.init(identifier: identifier, cellProviders: viewBuilder().items())
    }
}
