//
//  LNZWeakDictionary.swift
//  LNZWeakCollection
//
//  Created by Giuseppe Lanza on 05/02/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public class WeakDictionary<K: AnyObject&Hashable, V: AnyObject> {
    fileprivate typealias WeakToStrongType = [WeakHashableContainer<K>: V]
    fileprivate typealias StrongToWeakType = [K: WeakContainer<V>]
    
    public enum WeakType {
        case weakToStrong
        case strongToWeak
        
        fileprivate func toContainer() -> Container {
            switch self {
            case .weakToStrong: return .weakToStrong(container: WeakToStrongType())
            case .strongToWeak: return .strongToWeak(container: StrongToWeakType())
            }
        }
    }
    
    fileprivate enum Container {
        case weakToStrong(container: WeakToStrongType)
        case strongToWeak(container: StrongToWeakType)
        
        var keys: [K] {
            switch self {
            case .strongToWeak(let container): return Array(container.keys)
            case .weakToStrong(let container): return container.keys.compactMap { $0.weakReference }
            }
        }
        
        var values: [V] {
            switch self {
            case .strongToWeak(let container): return container.values.compactMap { $0.weakReference }
            case .weakToStrong(let container): return Array(container.values)
            }
        }
        
        mutating func cleanup() {
            switch self {
            case .strongToWeak(let container):
                var cleanContainer = container
                container.compactMap { (key, value) -> K? in return value.weakReference == nil ? key : nil }
                    .forEach{ (deadKey) in cleanContainer[deadKey] = nil }
                self = .strongToWeak(container: cleanContainer)
            case .weakToStrong(let container):
                var cleanContainer = container
                container.keys
                    .filter { $0.weakReference == nil }
                    .forEach { (deadKey) in
                        cleanContainer[deadKey] = nil
                }
                self = .weakToStrong(container: cleanContainer)
            }
        }
        
        subscript(key: K) -> V? {
            get {
                switch self {
                case .strongToWeak(let container):
                    return container[key]?.weakReference
                case .weakToStrong(let container):
                    let k = WeakHashableContainer(withObject: key)
                    return container[k]
                }
            }
            
            mutating set {
                switch self {
                case .strongToWeak(var container):
                    guard let value = newValue else {
                        container[key] = nil
                        return
                    }
                    let v = WeakContainer(weakReference: value)
                    container[key] = v
                    self = .strongToWeak(container: container)
                case .weakToStrong(var container):
                    let k = WeakHashableContainer(withObject: key)
                    container[k] = newValue
                    self = .weakToStrong(container: container)
                }
            }
        }
    }
    
    private let queue = DispatchQueue(label: "read-write", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent)
    
    private var weakReferenceContainer: Container

    public let type: WeakType

    public var count: Int {
        return keys.count
    }
    
    public var keys: [K] {
        cleanup()
        return queue.sync(flags: .barrier) {
            return weakReferenceContainer.keys
        }
    }
    
    public var values: [V] {
        cleanup()
        return queue.sync(flags: .barrier) {
            return weakReferenceContainer.values
        }
    }
    
    public init(withWeakRelation weakRelation: WeakType) {
        self.type = weakRelation
        weakReferenceContainer = weakRelation.toContainer()
    }
    
    public func set(_ object: V?, forKey key: K) {
        cleanup()
        queue.sync(flags: .barrier) {
            weakReferenceContainer[key] = object
        }
    }
    
    public func value(forKey key: K) -> V? {
        cleanup()
        return queue.sync {
            return weakReferenceContainer[key]
        }
    }
    
    func cleanup() {
        queue.sync(flags: .barrier) {
            weakReferenceContainer.cleanup()
        }
    }
    
    public subscript(key: K) -> V? {
        get { return value(forKey: key) }
        set { set(newValue, forKey: key) }
    }
}
