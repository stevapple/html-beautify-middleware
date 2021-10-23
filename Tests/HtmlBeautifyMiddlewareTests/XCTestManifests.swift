import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(HtmlBeautifyMiddlewareTests.allTests),
    ]
}
#endif
