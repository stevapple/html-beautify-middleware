// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "HtmlBeautifyMiddleware",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "HtmlBeautifyMiddleware",
            targets: ["HtmlBeautifyMiddleware"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "HtmlBeautifyMiddleware",
            dependencies: [
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "HtmlBeautifyMiddlewareTests",
            dependencies: [
                .target(name: "HtmlBeautifyMiddleware"),
                .product(name: "XCTVapor", package: "vapor"),
            ]
        ),
    ]
)
