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
        .library(
            name: "NnCredentialKitAccessibility",
            targets: ["NnCredentialKitAccessibility"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/nikolainobadi/NnTestKit", from: "1.0.0"),
        .package(url: "https://github.com/nikolainobadi/NnSwiftUIKit", from: "1.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "NnCredentialKit",
            dependencies: [
                "NnSwiftUIKit",
                "NnCredentialKitAccessibility",
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ],
            resources: [
                .process("Resources/Media.xcassets")
            ]
        ),
        .target(
            name: "NnCredentialKitAccessibility"
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
