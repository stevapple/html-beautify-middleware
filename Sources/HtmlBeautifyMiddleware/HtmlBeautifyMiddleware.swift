import SwiftSoup
import Vapor

/// A `Middleware` to beautify the served HTML with `SwiftSoup`.
public struct HtmlBeautifyMiddleware: Middleware {
    /// The length of indents in space.
    public let indent: UInt

    /// Media types to be beautified.
    public let mediaTypes: [MediaType]

    /// Create an `HtmlBeautifyMiddleware`.
    ///
    /// - Parameters:
    ///   - indent: The length of the indent in space.  Defaults to `2`.
    ///   - types: An array of media types to be beautified.  Defaults to `[.html]`.
    public init(indent: UInt = 2, accept types: [MediaType] = [.html]) {
        self.indent = indent
        self.mediaTypes = types
    }

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        next.respond(to: request).map { response in
            guard let contentType = response.headers.contentType?.serialize(),
                  let responseBody = response.body.string
            else {
                return response
            }
            if self.mediaTypes.map(\.rawValue).map(contentType.hasPrefix).contains(true) {
                do {
                    let html = try SwiftSoup.parse(responseBody)
                    html.outputSettings().indentAmount(indentAmount: self.indent).outline(outlineMode: false)
                    response.body = .init(string: try html.outerHtml())
                } catch Exception.Error(_, let message) {
                    request.logger.error("Parse HTML response failed: \(message)")
                } catch {
                    request.logger.error("Parse HTML response failed")
                }
            }
            return response
        }
    }

    /// Represents the media type from HTTP's `Content-Type` header, defined in [rfc2045](https://tools.ietf.org/html/rfc2045#section-5).
    public struct MediaType: RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: String) {
            self.init(rawValue: value)
        }

        public var description: String {
            self.rawValue
        }
    }
}

/// Convenience helpers for ``HtmlBeautifyMiddleware.MediaType``.
extension HtmlBeautifyMiddleware.MediaType {
    /// HTML media type.
    public static let html = Self(rawValue: "text/html")
    /// XML media type.
    public static let xml = Self(rawValue: "application/xml")

    /// Custom application media type.
    public static func application(_ type: String) -> Self {
        Self(rawValue: "application/\(type)")
    }

    /// Custom text media type.
    public static func text(_ type: String) -> Self {
        Self(rawValue: "text/\(type)")
    }
}
