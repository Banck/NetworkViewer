// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkViewer",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "NetworkViewer",
            targets: ["NetworkViewer"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NetworkViewer",
            dependencies: [],
            resources: [.process("Resources")]
        )
    ]
)
