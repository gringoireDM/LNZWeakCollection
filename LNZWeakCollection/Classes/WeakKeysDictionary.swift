//
//  LNZWeakDictionary.swift
//  LNZWeakCollection
//
//  Created by Giuseppe Lanza on 05/02/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public class WeakKeysDictionary<K: AnyObject&Hashable, V: AnyObject> {
    private let queue = DispatchQueue(label: "read-write", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: nil)
    
    private var weakReferenceContainer = [WeakHashableContainer<K>: V]()
    
    public var count: Int {
        return keys.count
    }
    
    public var keys: [K] {
        cleanup()
        return queue.sync(flags: .barrier) {
            return weakReferenceContainer.keys.flatMap { $0.weakReference }
        }
    }
    
    public var values: [V] {
        cleanup()
        return queue.sync(flags: .barrier) {
            return weakReferenceContainer.values.map { $0 as V }
        }
    }
    
    public init(){}

    
    
    public func set(_ object: V?, forKey key: K) {
        cleanup()
        queue.sync(flags: .barrier) {
            let k = WeakHashableContainer(withObject: key)
            weakReferenceContainer[k] = object
        }
    }
    
    public func value(forKey key: K) -> V? {
        cleanup()
        return queue.sync {
            let k = WeakHashableContainer(withObject: key)
            return weakReferenceContainer[k]
        }
    }
    
    func cleanup() {
        queue.sync(flags: .barrier) {
            weakReferenceContainer.keys
                .filter { $0.weakReference == nil }
                .forEach { (deadKey) in
                    weakReferenceContainer[deadKey] = nil
            }
        }
    }
    
    public subscript(key: K) -> V? {
        get { return value(forKey: key) }
        set { set(newValue, forKey: key) }
    }
}
