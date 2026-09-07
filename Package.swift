// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "macOSWindowShade",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "WindowShade",
            targets: ["WindowShade"]
        ),
        .executable(
            name: "WindowShadeExample",
            targets: ["WindowShadeExample"]
        )
    ],
    targets: [
        .target(name: "WindowShade"),
        .executableTarget(
            name: "WindowShadeExample",
            dependencies: ["WindowShade"],
            path: "Examples/WindowShadeExample"
        ),
        .testTarget(
            name: "WindowShadeTests",
            dependencies: ["WindowShade"]
        )
    ]
)
