import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftUINavigationHeaderTests.allTests),
    ]
}
#endif
