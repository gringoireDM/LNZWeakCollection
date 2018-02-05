//
//  WeakKeysDictionary.swift
//  LNZWeakCollectionTests
//
//  Created by Giuseppe Lanza on 05/02/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
@testable import LNZWeakCollection


class Key: NSObject {
    var keyValue: String
    
    init(withString value: String) {
        keyValue = value
    }
}

class WeakKeysDictionaryTests: XCTestCase {
    var weakDictionary = WeakKeysDictionary<Key, NSObject>()
    
    func testAdd() {
        let key = Key(withString: "Name")
        let value = NSObject()
        
        weakDictionary[key] = value
        
        XCTAssertEqual(value, weakDictionary[key])
    }
    
    func testWeakKey() {
        var key: Key! = Key(withString: "Name")
        let value = NSObject()
        
        weakDictionary[key] = value
        
        XCTAssertEqual(value, weakDictionary[key])
        key = nil
        XCTAssertNil(weakDictionary[Key(withString: "Name")])
    }
    
    
}
