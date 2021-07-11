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
    
    public init(
        identifier: String,
        reuseIdentifier: String = CellType.reuseIdentifier,
        height: @escaping (UITableView) -> CGFloat,
        heightEstimation: ((UITableView) -> CGFloat)? = nil,
        willShow: @escaping (CellType) -> Void = { _ in },
        didHide: @escaping (CellType) -> Void = { _ in },
        prefetch: @escaping () -> Void = { },
        cancelPrefetch: @escaping () -> Void = { },
        setup: @escaping (CellType) -> Void
    ) {
        super.init(
            identifier: identifier,
            reuseIdentifier: reuseIdentifier,
            height: height,
            heightEstimation: heightEstimation,
            willShow: { cell in
                guard let cell = cell as? CellType else { return }
                willShow(cell)
            },
            didHide: { cell in
                guard let cell = cell as? CellType else { return }
                didHide(cell)
            },
            prefetch: prefetch,
            cancelPrefetch: cancelPrefetch,
            setup: { cell in
                guard let cell = cell as? CellType else { return }
                setup(cell)
            }
        )
    }
    public convenience init(identifier: String, reuseIdentifier: String = CellType.reuseIdentifier, height: CGFloat, heightEstimation: ((UITableView) -> CGFloat)? = nil, willShow: @escaping (CellType)->Void = { _ in }, didHide: @escaping (CellType)->Void = { _ in }, prefetch: @escaping () -> Void = { }, cancelPrefetch: @escaping () -> Void = { }, setup: @escaping (CellType)->Void) {
        self.init(identifier: identifier, reuseIdentifier: reuseIdentifier, height: { _ in height }, heightEstimation: heightEstimation, willShow: willShow, didHide: didHide, prefetch: prefetch, cancelPrefetch: cancelPrefetch, setup: setup)
    }
    
}
