//
//  SectionProviderGenerator.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 22.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public class SectionProviderGenerator {
    var cellProviders: [CellProvider] = []
    func append(_ provider: CellProvider) {
        cellProviders.append(provider)
    }
}
extension SectionProviderGenerator {
    
    @discardableResult
    public static func |-- <V:CellProvider> (lpred: SectionProviderGenerator, rpred: V) -> SectionProviderGenerator {
        lpred.append(rpred)
        return lpred
    }
    
    @discardableResult
    public static func |-- <V:CellProvider> (lpred: SectionProviderGenerator, rpred: V?) -> SectionProviderGenerator {
        guard let rpred = rpred else { return lpred }
        lpred.append(rpred)
        return lpred
    }
    
    @discardableResult
    public static func |-- <V:CellProvider> (lpred: SectionProviderGenerator, rpred: [V]) -> SectionProviderGenerator {
        for provider in rpred { lpred.append(provider) }
        return lpred
    }
    
    @discardableResult
    public static func |-- (lpred: SectionProviderGenerator, rpred: [CellProvider]) -> SectionProviderGenerator {
        for provider in rpred { lpred.append(provider) }
        return lpred
    }
    
}

extension SectionProvider {
    public func provide(_ provider: (SectionProviderGenerator) -> Void) {
        let generator = SectionProviderGenerator()
        provider(generator)
        generator.cellProviders.add(to: self)
    }
    public static func make(_ identifier: String, _ maker: (SectionProviderGenerator) -> Void) -> SectionProvider {
        let result = SectionProvider(identifier, providersLoader: { _ in })
        result.provide(maker)
        return result
    }
}

public func If(_ expression: Bool, then: (SectionProviderGenerator) -> Void = { _ in }, `else`: (SectionProviderGenerator) -> Void = { _ in }) -> [CellProvider] {
    let generator = SectionProviderGenerator()
    if expression {
        then(generator)
    } else {
        `else`(generator)
    }
    return generator.cellProviders
}
