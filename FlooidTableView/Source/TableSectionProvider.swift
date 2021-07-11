//
//  TableSectionProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 11/07/2021.
//  Copyright © 2021 Martin Lalev. All rights reserved.
//

public struct TableSectionProvider {
    public let identifier: String
    public let cellProviders: [TableCellProvider]

    public init(identifier: String, cellProviders: [TableCellProvider]) {
        self.identifier = identifier
        self.cellProviders = cellProviders
    }
}
