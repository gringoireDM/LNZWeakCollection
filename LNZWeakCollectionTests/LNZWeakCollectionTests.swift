//
//  LNZWeakCollectionTests.swift
//  LNZWeakCollectionTests
//
//  Created by Giuseppe Lanza on 22/03/17.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import XCTest
@testable import LNZWeakCollection

class LNZWeakCollectionTests: XCTestCase {
    func testAdd() {
        var weakCollection = LNZWeakCollection<NSObject>()
        var objects = [NSObject]()
        for _ in 0..<10 {
            let object = NSObject()
            objects.append(object)
            weakCollection.add(object: object)
        }
        XCTAssertEqual(weakCollection.count, objects.count)
        
        //Adding the same object should not produce results
        weakCollection.add(object: objects[0])
        XCTAssertEqual(weakCollection.count, objects.count)

        weakCollection.execute { (obj) in
            XCTAssert(objects.contains(obj))
        }
    }
    
    func testRemove() {
        var weakCollection = LNZWeakCollection<NSObject>()
        var objects = [NSObject]()
        for _ in 0..<10 {
            let object = NSObject()
            objects.append(object)
            weakCollection.add(object: object)
        }
        
        var expectedCount = objects.count
        XCTAssertEqual(weakCollection.count, expectedCount)

        for object in objects {
            let removedObject = weakCollection.remove(object: object)
            expectedCount -= 1
            XCTAssertEqual(weakCollection.count, expectedCount)
            
            XCTAssertEqual(removedObject, object)
        }
        
        XCTAssertEqual(weakCollection.count, 0)
        
        let unexistingObject = NSObject()
        let removedObject = weakCollection.remove(object: unexistingObject)
        XCTAssertNil(removedObject)
    }
    
    func testCleanUp() {
        var object: NSObject? = NSObject()
        var weakCollection = LNZWeakCollection(with: object!)
        XCTAssertEqual(weakCollection.count, 1)
        
        weakCollection.cleanup()
        XCTAssertEqual(weakCollection.count, 1)
        
        object = nil
        weakCollection.cleanup()
        XCTAssertEqual(weakCollection.count, 0)
    }
    
    func testIterability() {
        var weakCollection = LNZWeakCollection<NSObject>()
        var objects = [NSObject]()
        for _ in 0..<10 {
            let object = NSObject()
            objects.append(object)
            weakCollection.add(object: object)
        }
        
        for (i, weakReference) in weakCollection.enumerated() {
            let object = objects[i]
            XCTAssertEqual(object, weakReference)
        }
    }
}
