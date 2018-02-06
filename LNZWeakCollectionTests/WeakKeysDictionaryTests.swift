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
    var hashValue: Int
    
    static func ==(lhs: Key, rhs: Key) -> Bool {
        return lhs.stringValue == rhs.stringValue
    }
    
    let stringValue: String
    
    init(withString value: String) {
        stringValue = value
        hashValue = value.hashValue
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
    
    func testWeakKey() {
        var key: Key! = Key(withString: "name")
        let value = NSObject()
        
        weakDictionary[key] = value
        
        XCTAssertEqual(value, weakDictionary[key])
        key = nil
        
        XCTAssertEqual(0, weakDictionary.count)
        XCTAssertNil(weakDictionary[Key(withString: "name")])
    }
}
