import SwiftSoup
import Vapor

public final class HtmlBeautifyMiddleware: Middleware {
    private let indent: UInt
    private let types: [ContentType]
    
    public init(indent: UInt = 2, accept types: [ContentType] = [.html]) {
        self.indent = indent
        self.types = types
    }
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).map { response in
            guard let contentType = response.headers.contentType else {
                return response
            }
            let filter = self.types.reduce(false) { (state, type) in
                contentType.description.hasPrefix(type.description) ? true : state
            }
            if filter {
                do {
                    let html = try SwiftSoup.parse(response.body.string!)
                    html.outputSettings().indentAmount(indentAmount: self.indent).outline(outlineMode: false)
                    response.body = .init(string: try html.outerHtml())
                } catch {}
            }
            return response
        }
    }
    
    public enum ContentType: CustomStringConvertible, Equatable, ExpressibleByStringLiteral {
        case html
        case text
        case custom(type: String)
        
        public var description: String {
            switch self {
                case .html:
                    return "text/html"
                case .text:
                    return "text/plain"
                case .custom(let type):
                    return type
            }
        }
        
        public init(stringLiteral value: String) {
            switch value {
                case "text/html":
                    self = .html
                case "text/plain":
                    self = .text
                default:
                    self = .custom(type: value)
            }
        }
    }
}
