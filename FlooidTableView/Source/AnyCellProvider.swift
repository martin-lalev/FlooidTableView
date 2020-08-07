//
//  AnyCellProvider.swift
//  FlooidTableView
//
//  Created by Martin Lalev on 7.07.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation
import UIKit

public class AnyCellProvider<CellType: IdentifiableCell>: CellProvider {
    
    private let setup: (CellType)->Void
    private let willShow: (CellType)->Void
    private let didHide: (CellType)->Void
    private let height: (UITableView) -> CGFloat
    private let heightEstimation: ((UITableView) -> CGFloat)?
    private let prefetcher: () -> Void
    private let cancelPrefetcher: () -> Void
    
    public let identifier: String
    
    public init(identifier: String, height: @escaping (UITableView) -> CGFloat, heightEstimation: ((UITableView) -> CGFloat)? = nil, willShow: @escaping (CellType)->Void = { _ in }, didHide: @escaping (CellType)->Void = { _ in }, prefetch: @escaping () -> Void = { }, cancelPrefetch: @escaping () -> Void = { }, setup: @escaping (CellType)->Void) {
        self.identifier = identifier
        self.height = height
        self.heightEstimation = heightEstimation
        self.setup = setup
        self.willShow = willShow
        self.didHide = didHide
        self.prefetcher = prefetch
        self.cancelPrefetcher = cancelPrefetch
    }
    public convenience init(identifier: String, height: CGFloat, heightEstimation: ((UITableView) -> CGFloat)? = nil, willShow: @escaping (CellType)->Void = { _ in }, didHide: @escaping (CellType)->Void = { _ in }, prefetch: @escaping () -> Void = { }, cancelPrefetch: @escaping () -> Void = { }, setup: @escaping (CellType)->Void) {
        self.init(identifier: identifier, height: { _ in height }, heightEstimation: heightEstimation, willShow: willShow, didHide: didHide, prefetch: prefetch, cancelPrefetch: cancelPrefetch, setup: setup)
    }
    
    public var reuseIdentifier: String {
        return CellType.reuseIdentifier
    }

    public func height(tableView: UITableView) -> CGFloat {
        return self.height(tableView)
    }
    
    public func estimatedHeight(tableView: UITableView) -> CGFloat {
        return self.heightEstimation?(tableView) ?? self.height(tableView)
    }
    
    public func setup(_ cell: UITableViewCell) {
        guard let cell = cell as? CellType else { return }
        self.setup(cell)
    }
    
    public func willShow(_ cell: UITableViewCell) {
        guard let cell = cell as? CellType else { return }
        self.willShow(cell)
    }
    
    public func didHide(_ cell: UITableViewCell) {
        guard let cell = cell as? CellType else { return }
        self.didHide(cell)
    }
    
    public func prefetch() {
        self.prefetcher()
    }

    public func cancelPrefetch() {
        self.cancelPrefetcher()
    }
    
}
