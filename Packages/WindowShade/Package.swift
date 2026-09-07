// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WindowShade",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "WindowShade",
            targets: ["WindowShade"]
        )
    ],
    targets: [
        .target(name: "WindowShade"),
        .testTarget(
            name: "WindowShadeTests",
            dependencies: ["WindowShade"]
        )
    ]
)
