//
//  DSL.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 22.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

precedencegroup SectionCellProviderAdditionPrecedence {
    lowerThan: AssignmentPrecedence
    associativity: left
}
infix operator |--: SectionCellProviderAdditionPrecedence
