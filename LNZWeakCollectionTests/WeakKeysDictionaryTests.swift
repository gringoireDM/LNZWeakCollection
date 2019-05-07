//
//  WeakKeysDictionary.swift
//  LNZWeakCollectionTests
//
//  Created by Giuseppe Lanza on 05/02/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
@testable import LNZWeakCollection

class Key: Hashable {
    static func ==(lhs: Key, rhs: Key) -> Bool {
        return lhs.stringValue == rhs.stringValue
    }
    
    let stringValue: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(stringValue)
    }
    
    init(withString value: String) {
        stringValue = value
    }
}

class WeakKeysDictionaryTests: XCTestCase {
    var weakDictionary = WeakDictionary<Key, NSObject>(withWeakRelation: .weakToStrong)
    
    func testAdd() {
        let key = Key(withString: "name")
        let value = NSObject()
        
        weakDictionary[key] = value
        
        XCTAssertEqual(value, weakDictionary[key])
    }
    
    func testThatEquivalentKeysFetchesTheSameValue() {
        let key = Key(withString: "name")
        let value = NSObject()
        
        weakDictionary[key] = value
        
        let newKey = Key(withString: "name")
        
        XCTAssertEqual(value, weakDictionary[newKey])
    }
    
    func testWeakKey() {
        var key: Key! = Key(withString: "name")
        let value = NSObject()
        
        weakDictionary[key] = value
        
        XCTAssertEqual(value, weakDictionary[key])
        
        autoreleasepool { key = nil }
        XCTAssertEqual(0, weakDictionary.count)
        XCTAssertNil(weakDictionary[Key(withString: "name")])
    }
    
    func testHashableContainer() {
        var a: NSObject? = NSObject()
        var b: NSObject? = NSObject()
        
        let aContainer = WeakHashableContainer(withObject: a!)
        let bContainer = WeakHashableContainer(withObject: b!)
        
        a = nil
        b = nil
        
        XCTAssertFalse(aContainer.hashValue == bContainer.hashValue)
        XCTAssertFalse(aContainer == bContainer)
    }
}
