//
//  LNZWeakDictionary.swift
//  LNZWeakCollection
//
//  Created by Giuseppe Lanza on 05/02/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public class WeakDictionary<K: AnyObject&Hashable, V: AnyObject> {
    private typealias WeakToStrongType = [WeakHashableContainer<K>: V]
    private typealias StrongToWeakType = [K: WeakContainer<V>]
    
    public enum WeakType {
        case weakToStrong
        case strongToWeak
        
        fileprivate func container() -> Any {
            switch self {
            case .weakToStrong: return WeakToStrongType()
            case .strongToWeak: return StrongToWeakType()
            }
        }
    }
    
    private let queue = DispatchQueue(label: "read-write", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: nil)
    
    private var weakReferenceContainer: Any

    public let type: WeakType

    public var count: Int {
        return keys.count
    }
    
    public var keys: [K] {
        cleanup()
        return queue.sync(flags: .barrier) {
            switch type {
            case .weakToStrong: return (weakReferenceContainer as! WeakToStrongType).keys.flatMap { $0.weakReference }
            case .strongToWeak: return Array((weakReferenceContainer as! StrongToWeakType).keys)
            }
        }
    }
    
    public var values: [V] {
        cleanup()
        return queue.sync(flags: .barrier) {
            switch type {
            case .weakToStrong: return Array((weakReferenceContainer as! WeakToStrongType).values)
            case .strongToWeak: return (weakReferenceContainer as! StrongToWeakType).values.flatMap { $0.weakReference }
            }
        }
    }
    
    public init(withWeakRelation weakRelation: WeakType) {
        self.type = weakRelation
        weakReferenceContainer = weakRelation.container()
    }
    
    public func set(_ object: V?, forKey key: K) {
        cleanup()
        queue.sync(flags: .barrier) {
            switch type {
            case .weakToStrong:
                var mutable = (weakReferenceContainer as! WeakToStrongType)

                let k = WeakHashableContainer(withObject: key)
                mutable[k] = object
                weakReferenceContainer = mutable
            case .strongToWeak:
                var mutable = (weakReferenceContainer as! StrongToWeakType)
                
                guard let value = object else {
                    mutable[key] = nil
                    weakReferenceContainer = mutable
                    return
                }
                
                let v = WeakContainer(weakReference: value)
                mutable[key] = v
                weakReferenceContainer = mutable
            }
        }
    }
    
    public func value(forKey key: K) -> V? {
        cleanup()
        return queue.sync {
            switch type {
            case .weakToStrong:
                let k = WeakHashableContainer(withObject: key)
                return (weakReferenceContainer as! WeakToStrongType)[k]
            case .strongToWeak:
                return (weakReferenceContainer as! StrongToWeakType)[key]?.weakReference
            }
        }
    }
    
    func cleanup() {
        queue.sync(flags: .barrier) {
            switch type {
            case .weakToStrong:
                var mutable = (weakReferenceContainer as! WeakToStrongType)
                mutable.keys
                    .filter { $0.weakReference == nil }
                    .forEach { (deadKey) in
                        mutable[deadKey] = nil
                }
                weakReferenceContainer = mutable
            case .strongToWeak:
                var mutable = (weakReferenceContainer as! StrongToWeakType)
                mutable.flatMap { (key, value) -> K? in return value.weakReference == nil ? key : nil }
                    .forEach{ (deadKey) in mutable[deadKey] = nil }
                weakReferenceContainer = mutable
            }
        }
    }
    
    public subscript(key: K) -> V? {
        get { return value(forKey: key) }
        set { set(newValue, forKey: key) }
    }
}
