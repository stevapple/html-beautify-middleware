# HtmlBeautifyMiddleware: Beautifies Your HTML Files

![Vapor](https://img.shields.io/badge/Vapor-4-green.svg)
![Swift](https://img.shields.io/badge/Swift-5.2-orange.svg)
![Release](https://img.shields.io/github/v/tag/stevapple/HtmlBeautifyMiddleware?label=release)
![License](https://img.shields.io/github/license/stevapple/HtmlBeautifyMiddleware)
![Test](https://github.com/stevapple/HtmlBeautifyMiddleware/workflows/Test/badge.svg)

HtmlBeautifyMiddleware is a [Vapor 4](https://github.com/vapor/vapor) middleware which beautifies all the HTML files served.

You can use it with [Leaf](https://github.com/vapor/leaf), the templating language for Swift and Vapor. 

## Usage

You can enable it globally by registering it to `app`:

```swift
// Sources/App/configure.swift

import Vapor
import HtmlBeautifyMiddleware

public func configure(_ app: Application) throws {
    // Use HtmlBeautifyMiddleware
    app.middleware.use(HtmlBeautifyMiddleware())
    try routes(app)
}
```

Alternatively, register it to specific routes with `app.grouped`:

```swift
// Sources/App/routes.swift

import Vapor
import HtmlBeautifyMiddleware

func routes(_ app: Application) throws {
    let htmlBeautified = app.grouped(HtmlBeautifyMiddleware())
    // Register routes to htmlBeautified then
    htmlBeautified.get("xxx") {
        // ...
    }
}
```

## Config

`HtmlBeautifyMiddleware.init` accepts two parameters: 

- `indent: UInt` controls how many spaces is the indent composed of, defaults to `2`;
- `accept: [HtmlBeautifyMiddleware.ContentType]` controls which kinds of content should be beatified, defaults to `[.html]`.

`HtmlBeautifyMiddleware.ContentType` refers to the `MIME` type specified in the `Content-Type` header:

- `.html` refers to `text/html`;
- `.text` refers to `text/plain`;
- `.custom(type: String)` refers to any MIME type represented by `type`. 

You can use `String` exprerssions too:

```swift
let beautifyMiddleware = HtmlBeautifyMiddleware(indent: 4, accept: ["text/html", "application/leaf"])
```