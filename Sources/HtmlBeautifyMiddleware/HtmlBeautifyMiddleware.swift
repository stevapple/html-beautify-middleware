import SwiftSoup
import Vapor

public struct HtmlBeautifyMiddleware: Middleware {
    public let indent: UInt
    public let mediaTypes: [MediaType]

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

extension HtmlBeautifyMiddleware.MediaType {
    public static let html = Self(rawValue: "text/html")
    public static let xml = Self(rawValue: "application/xml")

    public static func application(_ type: String) -> Self {
        Self(rawValue: "application/\(type)")
    }

    public static func text(_ type: String) -> Self {
        Self(rawValue: "text/\(type)")
    }
}
