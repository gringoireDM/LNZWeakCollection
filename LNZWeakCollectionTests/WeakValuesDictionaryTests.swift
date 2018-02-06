//
//  WeakValuesDictionaryTests.swift
//  LNZWeakCollectionTests
//
//  Created by Giuseppe Lanza on 06/02/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
@testable import LNZWeakCollection

class WeakValuesDictionaryTests: XCTestCase {
    
    var weakDictionary = WeakDictionary<NSString, NSObject>(withWeakRelation: .strongToWeak)
    
    func testAdd() {
        let key = "Name" as NSString
        let value = NSObject()
        
        weakDictionary[key] = value
        
        XCTAssertEqual(value, weakDictionary[key])
    }
    
    func testWeakKey() {
        let key = "Name" as NSString
        var value: NSObject? = NSObject()
        
        weakDictionary[key] = value
        
        XCTAssertEqual(value, weakDictionary[key])
        value = nil
        
        XCTAssertEqual(0, weakDictionary.count)
        XCTAssertNil(weakDictionary["Name"])
    }

}
