// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SubscriptionTracker",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SubscriptionTracker",
            targets: ["SubscriptionTracker"]),
    ],
    targets: [
        .target(
            name: "SubscriptionTracker",
            path: ".",
            exclude: [
                "Tests",
                "Preview Content"
            ],
            sources: [
                "Models",
                "Views",
                "Services",
                "SubscriptionTrackerApp.swift",
                "ContentView.swift"
            ]
        ),
        .testTarget(
            name: "SubscriptionTrackerTests",
            dependencies: ["SubscriptionTracker"],
            path: "Tests"
        ),
    ]
)
