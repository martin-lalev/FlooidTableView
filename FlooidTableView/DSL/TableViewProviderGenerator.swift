//
//  TableViewProviderGenerator.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 22.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public class TableViewProviderGenerator {
    var sectionProviders: [SectionProvider] = []
    func append(_ provider: SectionProvider) {
        sectionProviders.append(provider)
    }
}
extension TableViewProviderGenerator {
    
    @discardableResult
    public static func |-- <V:SectionProvider> (lpred: TableViewProviderGenerator, rpred: V) -> TableViewProviderGenerator {
        lpred.append(rpred)
        return lpred
    }
    
    @discardableResult
    public static func |-- <V:SectionProvider> (lpred: TableViewProviderGenerator, rpred: V?) -> TableViewProviderGenerator {
        guard let rpred = rpred else { return lpred }
        lpred.append(rpred)
        return lpred
    }
    
    @discardableResult
    public static func |-- <V:SectionProvider> (lpred: TableViewProviderGenerator, rpred: [V]) -> TableViewProviderGenerator {
        for provider in rpred { lpred.append(provider) }
        return lpred
    }
    
    @discardableResult
    public static func |-- (lpred: TableViewProviderGenerator, rpred: [SectionProvider]) -> TableViewProviderGenerator {
        for provider in rpred { lpred.append(provider) }
        return lpred
    }
    
}

extension TableProvider {
    public func provide(_ provider: (TableViewProviderGenerator) -> Void) {
        let generator = TableViewProviderGenerator()
        provider(generator)
        generator.sectionProviders.add(to: self)
    }
    public static func make(_ identifier: String, _ maker: (TableViewProviderGenerator) -> Void) -> TableProvider {
        let result = TableProvider(tableLoader: { _ in })
        result.provide(maker)
        return result
    }
}

public func If(_ expression: Bool, then: (TableViewProviderGenerator) -> Void = { _ in }, `else`: (TableViewProviderGenerator) -> Void = { _ in }) -> [SectionProvider] {
    let generator = TableViewProviderGenerator()
    if expression {
        then(generator)
    } else {
        `else`(generator)
    }
    return generator.sectionProviders
}
