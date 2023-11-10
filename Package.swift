// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkViewer",
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
            dependencies: []
        )
    ]
)
