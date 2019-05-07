//
//  LNZWeakContainer.swift
//  LNZWeakCollection
//
//  Created by Giuseppe Lanza on 22/03/17.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import Foundation

public struct WeakContainer<T: AnyObject> {
    public weak var weakReference: T?
}

public struct WeakHashableContainer<T: AnyObject&Hashable>: Hashable {
    public weak var weakReference: T?
    
    let hashing: Int
    
    init(withObject object: T) {
        weakReference = object
        hashing = object.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashing)
    }
    
    public static func ==(lhs: WeakHashableContainer<T>, rhs: WeakHashableContainer<T>) -> Bool {
        switch (lhs.weakReference, rhs.weakReference) {
        case let (.some(a), .some(b)): return a == b
        case (.some, .none), (.none, .some): return false
        case (.none, .none): return lhs.hashValue == rhs.hashValue
        }
    }
}
