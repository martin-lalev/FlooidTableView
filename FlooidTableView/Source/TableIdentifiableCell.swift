//
//  TableIdentifiableCell.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 11/07/2021.
//  Copyright © 2021 Martin Lalev. All rights reserved.
//

import UIKit

public protocol TableIdentifiableCell: UITableViewCell {
    static var reuseIdentifier: String { get }
    static func register(in view: UITableView)
}

public extension TableIdentifiableCell {
    static func makeCell(
        identifier: String,
        reuseIdentifier: String = Self.reuseIdentifier,
        heightIdentifier: String? = nil,
        height: @escaping (UITableView) -> CGFloat,
        heightEstimation: ((UITableView) -> CGFloat)? = nil,
        willShow: @escaping (Self) -> Void = { _ in },
        didHide: @escaping (Self) -> Void = { _ in },
        prefetch: @escaping () -> Void = { },
        cancelPrefetch: @escaping () -> Void = { },
        setup: @escaping (Self) -> Void
    ) -> TableCellProvider {
        .init(
            identifier: identifier,
            reuseIdentifier: reuseIdentifier,
            heightIdentifier: heightIdentifier,
            height: height,
            heightEstimation: heightEstimation,
            willShow: { cell in
                guard let cell = cell as? Self else { return }
                willShow(cell)
            },
            didHide: { cell in
                guard let cell = cell as? Self else { return }
                didHide(cell)
            },
            prefetch: prefetch,
            cancelPrefetch: cancelPrefetch,
            setup: { cell in
                guard let cell = cell as? Self else { return }
                setup(cell)
            }
        )
    }
    static func makeCell(identifier: String, reuseIdentifier: String = Self.reuseIdentifier, heightIdentifier: String? = nil, height: CGFloat, heightEstimation: ((UITableView) -> CGFloat)? = nil, willShow: @escaping (Self)->Void = { _ in }, didHide: @escaping (Self)->Void = { _ in }, prefetch: @escaping () -> Void = { }, cancelPrefetch: @escaping () -> Void = { }, setup: @escaping (Self)->Void) -> TableCellProvider {
        self.makeCell(identifier: identifier, reuseIdentifier: reuseIdentifier, heightIdentifier: heightIdentifier, height: { _ in height }, heightEstimation: heightEstimation, willShow: willShow, didHide: didHide, prefetch: prefetch, cancelPrefetch: cancelPrefetch, setup: setup)
    }
}

extension UITableView {

    public func register(_ cellTypes: [TableIdentifiableCell.Type] = []) {
        for cellType in cellTypes {
            cellType.register(in: self)
        }
    }
    public func register(_ cellTypes: TableIdentifiableCell.Type ...) {
        self.register(cellTypes)
    }

}
