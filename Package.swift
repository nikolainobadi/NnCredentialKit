// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NnCredentialKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "NnCredentialKit",
            targets: ["NnCredentialKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nikolainobadi/NnSwiftUIKit", branch: "main")
    ],
    targets: [
        .target(
            name: "NnCredentialKit",
            dependencies: [
                "NnSwiftUIKit"
            ],
            resources: [
                .process("Resources/Media.xcassets")
            ]
        ),
        .testTarget(
            name: "NnCredentialKitTests",
            dependencies: ["NnCredentialKit"]
        ),
    ]
)
