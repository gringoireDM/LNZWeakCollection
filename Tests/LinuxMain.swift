import XCTest

import EnumKitTests

var tests = [XCTestCaseEntry]()
tests += WeakCollectionTests.allTests
tests += WeakKeysDictionaryTests.allTests
tests += WeakValuesDictionaryTests.allTests

XCTMain(tests)
