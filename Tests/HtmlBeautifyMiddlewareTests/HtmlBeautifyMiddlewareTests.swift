@testable import HtmlBeautifyMiddleware
import XCTest
import XCTVapor

final class HtmlBeautifyMiddlewareTests: XCTestCase {
    let renderer: (Request) -> View = { (_: Request) -> View in

        var result = ByteBufferAllocator().buffer(capacity: 0)

        result.writeString("""
        <!doctype html>
        <html> <head> <title> 1111 </title> <body>
        <h1> 11
        </h1> 12
        </body>\t</html>
        """)

        return View(data: result)
    }

    func testBeautifier() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.grouped(
            HtmlBeautifyMiddleware()
        ).get("test1", use: self.renderer)

        app.grouped(
            HtmlBeautifyMiddleware(indent: 0)
        ).get("test2", use: self.renderer)

        try app.testable().test(.GET, "/test1") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string.splitTrimmed, """
            <!doctype html>
            <html>
              <head>
                <title> 1111 </title>
              </head>
              <body>
                <h1> 11 </h1> 12
              </body>
            </html>
            """.splitTrimmed)
        }

        try app.testable().test(.GET, "/test2") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string.splitTrimmed, """
            <!doctype html>
            <html>
            <head>
            <title> 1111 </title>
            </head>
            <body>
            <h1> 11 </h1> 12
            </body>
            </html>
            """.splitTrimmed)
        }
    }

    func testContentType() throws {
        XCTAssertEqual("text/html", HtmlBeautifyMiddleware.ContentType.html)
        XCTAssertEqual("application/leaf", HtmlBeautifyMiddleware.ContentType.custom(type: "application/leaf"))
    }

    static var allTests = [
        ("testBeautifier", testBeautifier),
        ("testContentType", testContentType),
    ]
}

extension String {
    fileprivate var splitTrimmed: [String] {
        self.split(separator: "\n").map {
            String(
                ("/" + $0).trimmingCharacters(in: .whitespacesAndNewlines).dropFirst()
            )
        }
    }
}
