// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NnCredentialKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NnCredentialKit",
            targets: ["NnCredentialKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nikolainobadi/NnTestKit", branch: "main"),
        .package(url: "https://github.com/nikolainobadi/NnSwiftUIKit", branch: "main"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "NnCredentialKit",
            dependencies: [
                "NnSwiftUIKit",
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ],
            resources: [
                .process("Resources/Media.xcassets")
            ]
        ),
        .testTarget(
            name: "NnCredentialKitTests",
            dependencies: [
                "NnCredentialKit",
                .product(name: "NnTestHelpers", package: "NnTestKit")
            ]
        ),
    ]
)
