// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NnCredentialKit",
    platforms: [
        .iOS(.v16)
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
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "NnCredentialKit",
            dependencies: [
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
                "NnCredentialKit"
            ]
        ),
    ]
)
