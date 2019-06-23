//
//  TableViewProviderGenerator.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 22.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public class TableViewProviderGenerator {
    public var sectionProviders: [SectionProvider] = []
    public init() {}
    public func append(_ provider: SectionProvider) {
        self.sectionProviders.append(provider)
    }

    public static func make(_ provider: (TableViewProviderGenerator) -> Void) -> TableViewProviderGenerator {
        let generator = TableViewProviderGenerator()
        provider(generator)
        return generator
    }
}
extension TableViewProviderGenerator {
    
    @discardableResult
    public static func |-- (lpred: TableViewProviderGenerator, rpred: SectionProvider) -> TableViewProviderGenerator {
        lpred.append(rpred)
        return lpred
    }
    
    @discardableResult
    public static func |-- (lpred: TableViewProviderGenerator, rpred: SectionProvider?) -> TableViewProviderGenerator {
        guard let rpred = rpred else { return lpred }
        lpred.append(rpred)
        return lpred
    }
    
    @discardableResult
    public static func |-- (lpred: TableViewProviderGenerator, rpred: [SectionProvider]) -> TableViewProviderGenerator {
        for provider in rpred { lpred.append(provider) }
        return lpred
    }
    
}

public func If(_ expression: Bool, then: (TableViewProviderGenerator) -> Void = { _ in }, `else`: (TableViewProviderGenerator) -> Void = { _ in }) -> [SectionProvider] {
    if expression {
        return TableViewProviderGenerator.make(then).sectionProviders
    } else {
        return TableViewProviderGenerator.make(`else`).sectionProviders
    }
}

public func Unwrap<T>(_ value: T?, then: (TableViewProviderGenerator, T) -> Void = { _, _ in }, `else`: (TableViewProviderGenerator) -> Void = { _ in }) -> [SectionProvider] {
    let generator = TableViewProviderGenerator()
    if let value = value {
        then(generator, value)
    } else {
        `else`(generator)
    }
    return generator.sectionProviders
}
