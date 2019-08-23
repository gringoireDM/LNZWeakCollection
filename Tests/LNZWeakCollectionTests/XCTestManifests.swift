import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WeakCollectionTests.allTests),
        testCase(WeakKeysDictionaryTests.allTests),
        testCase(WeakValuesDictionaryTests.allTests),
    ]
}
#endif
