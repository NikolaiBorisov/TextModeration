// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TextModeration",
    products: [
        .library(
            name: "TextModeration",
            targets: ["TextModeration"]
        ),
    ],
    targets: [
        .target(
            name: "TextModeration"
        ),
        .testTarget(
            name: "TextModerationTests",
            dependencies: ["TextModeration"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
