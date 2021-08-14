//
//  TableCellProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 13.06.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import UIKit

public struct TableCellProvider {
    
    public let identifier: String
    public let reuseIdentifier: String
    public let heightIdentifier: String

    private let height: (UITableView) -> CGFloat
    private let heightEstimation: ((UITableView) -> CGFloat)?

    private let setup: (UITableViewCell)->Void
    private let willShow: (UITableViewCell)->Void
    private let didHide: (UITableViewCell)->Void
    private let prefetcher: () -> Void
    private let cancelPrefetcher: () -> Void
    
    public init(identifier: String, reuseIdentifier: String, heightIdentifier: String? = nil, height: @escaping (UITableView) -> CGFloat, heightEstimation: ((UITableView) -> CGFloat)? = nil, willShow: @escaping (UITableViewCell)->Void = { _ in }, didHide: @escaping (UITableViewCell)->Void = { _ in }, prefetch: @escaping () -> Void = { }, cancelPrefetch: @escaping () -> Void = { }, setup: @escaping (UITableViewCell)->Void) {
        self.identifier = identifier
        self.reuseIdentifier = reuseIdentifier
        self.heightIdentifier = heightIdentifier ?? identifier
        self.height = height
        self.heightEstimation = heightEstimation
        self.setup = setup
        self.willShow = willShow
        self.didHide = didHide
        self.prefetcher = prefetch
        self.cancelPrefetcher = cancelPrefetch
    }
    
    public init(identifier: String, reuseIdentifier: String, heightIdentifier: String? = nil, height: CGFloat, heightEstimation: ((UITableView) -> CGFloat)? = nil, willShow: @escaping (UITableViewCell)->Void = { _ in }, didHide: @escaping (UITableViewCell)->Void = { _ in }, prefetch: @escaping () -> Void = { }, cancelPrefetch: @escaping () -> Void = { }, setup: @escaping (UITableViewCell)->Void) {
        self.init(identifier: identifier, reuseIdentifier: reuseIdentifier, heightIdentifier: heightIdentifier, height: { _ in height }, heightEstimation: heightEstimation, willShow: willShow, didHide: didHide, prefetch: prefetch, cancelPrefetch: cancelPrefetch, setup: setup)
    }

    public func height(tableView: UITableView) -> CGFloat {
        return self.height(tableView)
    }
    
    public func estimatedHeight(tableView: UITableView) -> CGFloat {
        return self.heightEstimation?(tableView) ?? self.height(tableView)
    }
    
    public func setup(_ cell: UITableViewCell) {
        self.setup(cell)
    }
    
    public func willShow(_ cell: UITableViewCell) {
        self.willShow(cell)
    }
    
    public func didHide(_ cell: UITableViewCell) {
        self.didHide(cell)
    }
    
    public func prefetch() {
        self.prefetcher()
    }

    public func cancelPrefetch() {
        self.cancelPrefetcher()
    }
    
}

extension TableCellProvider: Identifiable {
    public var id: String { self.identifier }
}
