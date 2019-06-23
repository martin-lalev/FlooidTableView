//
//  SectionProviderGenerator.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 22.06.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public class SectionProviderGenerator {
    public var cellProviders: [CellProvider] = []
    public init() {}
    public func append(_ provider: CellProvider) {
        cellProviders.append(provider)
    }
    
    public static func make(_ provider: (SectionProviderGenerator) -> Void) -> SectionProviderGenerator {
        let generator = SectionProviderGenerator()
        provider(generator)
        return generator
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

public func If(_ expression: Bool, then: (SectionProviderGenerator) -> Void = { _ in }, `else`: (SectionProviderGenerator) -> Void = { _ in }) -> [CellProvider] {
    if expression {
        return SectionProviderGenerator.make(then).cellProviders
    } else {
        return SectionProviderGenerator.make(`else`).cellProviders
    }
}

public func Unwrap<T>(_ value: T?, then: (SectionProviderGenerator, T) -> Void = { _, _ in }, `else`: (SectionProviderGenerator) -> Void = { _ in }) -> [CellProvider] {
    let generator = SectionProviderGenerator()
    if let value = value {
        then(generator, value)
    } else {
        `else`(generator)
    }
    return generator.cellProviders
}
