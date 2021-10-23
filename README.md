# HtmlBeautifyMiddleware: Beautifies Your HTML Files

![Vapor](https://img.shields.io/badge/Vapor-4-green.svg?logo=vapor)
![Swift](https://img.shields.io/badge/Swift->=5.2-orange.svg?logo=swift)
![License](https://img.shields.io/github/license/stevapple/HtmlBeautifyMiddleware)  
![Release](https://img.shields.io/github/v/tag/stevapple/HtmlBeautifyMiddleware?label=release)
![Test](https://github.com/stevapple/HtmlBeautifyMiddleware/workflows/Test/badge.svg)

`HtmlBeautifyMiddleware` is a [Vapor 4](https://github.com/vapor/vapor) middleware which can beautify all the HTML files served by Vapor.

You can use it with [Leaf](https://github.com/vapor/leaf), the template language for Swift and Vapor.

## Add to your project

Add `HtmlBeautifyMiddleware` to your SwiftPM project by specifying the following package dependency in `Package.swift`:

```swift
.package(url: "https://github.com/stevapple/html-beautify-middleware", from: "1.0.0")
```

Then add the product in your target's dependencies:

```swift
.product(name: "HtmlBeautifyMiddleware", package: "html-beautify-middleware")
```

## Use with Vapor

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

You may provide extra config to get custom behavior:

```swift
app.middleware.use(
    HtmlBeautifyMiddleware(indent: 4, accept: [.html, .application("x-html")])
)
```
