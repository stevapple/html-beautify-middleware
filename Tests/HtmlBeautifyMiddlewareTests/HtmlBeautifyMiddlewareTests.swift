import HtmlBeautifyMiddleware
import XCTest
import XCTVapor

final class HtmlBeautifyMiddlewareTests: XCTestCase {
    let renderer: (Request) -> View = { _ in
        var result = ByteBufferAllocator().buffer(capacity: 0)

        result.writeString("""
        <!DOCTYPE html>
        <html> <head> <title> 1111 </title> <body>
        <h1> 11
        </h1> 12
        </body>\t</html>
        """)

        return View(data: result)
    }

    let markdownRenderer: (Request) -> View = { _ in
        var result = ByteBufferAllocator().buffer(capacity: 0)

        result.writeString("""
        # The Title

        This is a Markdown file.

        It may be mixed with some HTML.

        <hr />
        """)

        return View(data: result)
    }

    func testDefaultBeautifier() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.middleware.use(HtmlBeautifyMiddleware())

        app.get("test", use: self.renderer)

        try app.testable().test(.GET, "/test") { res in
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

    func testCustomBeautifier() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.grouped(
            HtmlBeautifyMiddleware(indent: 4)
        ).get("test1", use: self.renderer)

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

        app.grouped(
            HtmlBeautifyMiddleware(indent: 0)
        ).get("test2", use: self.renderer)

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

    func testNotHTML() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.middleware.use(HtmlBeautifyMiddleware())

        app.get("test", use: self.markdownRenderer)

        try app.testable().test(.GET, "/test") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string.splitTrimmed, """
            # The Title

            This is a Markdown file.

            It may be mixed with some HTML.

            <hr />
            """.splitTrimmed)
        }
    }

    func testMediaType() throws {
        XCTAssertEqual("text/html", HtmlBeautifyMiddleware.MediaType.html.rawValue)
        XCTAssertEqual("application/leaf", HtmlBeautifyMiddleware.MediaType.application("leaf").rawValue)
    }
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
