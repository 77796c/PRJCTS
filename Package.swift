// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SubscriptionsApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SubscriptionsApp",
            targets: ["SubscriptionsApp"]
        )
    ],
    targets: [
        .target(
            name: "SubscriptionsApp",
            path: "Sources/SubscriptionsApp"
        ),
        .testTarget(
            name: "SubscriptionsAppTests",
            dependencies: ["SubscriptionsApp"],
            path: "Tests/SubscriptionsAppTests"
        )
    ]
)
