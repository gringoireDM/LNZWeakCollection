//
//  LNZWeakCollection.swift
//  LNZWeakCollection
//
//  Created by Giuseppe Lanza on 22/03/17.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import Foundation

public struct WeakCollection<T: AnyObject>: Sequence, IteratorProtocol {
    private let queue = DispatchQueue(label: "read-write", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: nil)
    private var weakReferecesContainers: [WeakContainer<T>] = [WeakContainer<T>]()
    private var currentIndex: Int = 0
    
    ///The count of nonnil objects stored in the array
    public var count: Int { return weakReferences.count }
    
    ///All the nonnil objects in the collection
    public var weakReferences: [T] { return weakReferecesContainers.compactMap({ return $0.weakReference }) }
    
    public init(){}
    
    /**
     Add an object to the collection. A weak reference to this object will
     be stored in the collection.
     
     - parameter object: The object to be stored in the collection. If this
     object is deallocated it will be removed from the collection. This collection
     does not have strong references to the object.
     */
    public mutating func add(object: T) {
        cleanup()
        queue.sync(flags: .barrier) {
            guard weakReferecesContainers.filter({ $0.weakReference === object}).count == 0 else { return }
            
            let container = WeakContainer(weakReference: object)
            weakReferecesContainers.append(container)
        }
    }
    
    /**
     Remove an object from the stack, if the object is actually in the collection.
     Else this method will produce no results.
     
     - parameter object: The object to be removed.
     */
    @discardableResult public mutating func remove(object: T)-> T? {
        cleanup()
        return queue.sync(flags: .barrier) {
            guard let index = weakReferecesContainers.index(where: { $0.weakReference === object }) else { return nil }
            return weakReferecesContainers.remove(at: index).weakReference
        }
    }
    
    /**
     Execute a closure for each weak object still alive. This method will cause the cleanup
     of the collection if needed.
     
     - parameter closure: The closure to be executed. Just nonnil objects will be executed.
     */
    public mutating func execute(_ closure: ((_ object: T) throws -> Void)) rethrows {
        cleanup()
        try queue.sync(flags: .barrier) {
            try weakReferecesContainers.forEach { (weakContainer) in
                guard let weakReference = weakContainer.weakReference else { return }
                try closure(weakReference)
            }
        }
    }
    
    ///Clean all the weak objects that are now nil
    mutating func cleanup() {
        queue.sync(flags: .barrier) {
            while let index = weakReferecesContainers.index(where: { $0.weakReference == nil }) {
                weakReferecesContainers.remove(at: index)
                if index < currentIndex {
                    currentIndex -= 1
                }
            }
        }
    }
    
    //MARK: IteratorProtocol and Sequence conformance
    
    public mutating func next() -> T? {
        cleanup()
        return queue.sync(flags: .barrier) {
            guard count > 0 && currentIndex < count else { return nil }
            let object = weakReferences[currentIndex]
            currentIndex += 1
            return object
        }
    }
}
