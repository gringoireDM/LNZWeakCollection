//
//  LNZWeakCollection.swift
//  LNZWeakCollection
//
//  Created by Giuseppe Lanza on 22/03/17.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import Foundation

fileprivate func synced(_ lock: AnyObject, closure: (() throws ->  Void)) rethrows {
    objc_sync_enter(lock)
    try closure()
    objc_sync_exit(lock)
}

public struct LNZWeakCollection<T>: CustomStringConvertible, Sequence, IteratorProtocol {
    private var weakReferecesContainers: [LNZWeakContainer<AnyObject>] = [LNZWeakContainer<AnyObject>]()
    private var currentIndex: Int = 0
    private let lockObject = NSObject()
    
    ///The count of nonnil objects stored in the array
    public var count: Int { return weakReferences.count }
    
    ///All the nonnil objects in the collection
    public var weakReferences: [T] { return weakReferecesContainers.flatMap({ return $0.weakReference as? T }) }
    
    public init(){}
    
    public init(with weakReference: T) {
        add(object: weakReference)
    }
    
    /**
     Add an object to the collection. A weak reference to this object will
     be stored in the collection.
     
     - parameter object: The object to be stored in the collection. If this
     object is deallocated it will be removed from the collection. This collection
     does not have strong references to the object.
     */
    public mutating func add(object: T) {
        synced(lockObject) {
            guard weakReferecesContainers.filter({ $0.weakReference === object as AnyObject}).count == 0 else { return }
            
            let container = LNZWeakContainer(weakReference: object as AnyObject)
            weakReferecesContainers.append(container)
        }
    }
    
    /**
     Remove an object from the stack, if the object is actually in the collection.
     Else this method will produce no results.
     
     - parameter object: The object to be removed.
     */
    @discardableResult public mutating func remove(object: T)-> T? {
        var result: T?
        synced(lockObject) {
            guard let index = weakReferecesContainers.index(where: { $0.weakReference === object as AnyObject }) else { return }
            result = weakReferecesContainers.remove(at: index).weakReference as? T
        }
        
        return result
    }
    
    /**
     Execute a closure for each weak object still alive. This method will cause the cleanup
     of the collection if needed.
     
     - parameter closure: The closure to be executed. Just nonnil objects will be executed.
     */
    public mutating func execute(_ closure: ((_ object: T) throws -> Void)) rethrows {
        cleanup()
        try synced(lockObject) {
            try weakReferecesContainers.forEach { (weakContainer) in
                guard let weakReference = weakContainer.weakReference as? T else { return }
                try closure(weakReference)
            }
        }
    }
    
    ///Clean all the weak objects that are now nil
    internal mutating func cleanup() {
        synced(lockObject) {
            while let index = weakReferecesContainers.index(where: { $0.weakReference == nil }) {
                weakReferecesContainers.remove(at: index)
                if index < currentIndex {
                    currentIndex -= 1
                }
            }
        }
    }
    
    //MARK: CustomStringConvertible conformance
    
    public var description: String {
        let descriptions = weakReferecesContainers.map { return $0.weakReference?.description ?? "nil" }
        return descriptions.description
    }
    
    //MARK: IteratorProtocol and Sequence conformance
    
    public mutating func next() -> T? {
        cleanup()
        var result: T?
        synced(lockObject) { 
            guard count > 0 && currentIndex < count else { return }
            let object = weakReferences[currentIndex]
            currentIndex += 1
            result = object
        }
        return result
    }
}
