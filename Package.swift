// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Subuddy",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SubuddyCore",
            targets: ["SubuddyCore"]
        )
    ],
    targets: [
        .target(
            name: "SubuddyCore",
            dependencies: [],
            path: "Sources/SubuddyCore"
        ),
        .testTarget(
            name: "SubuddyCoreTests",
            dependencies: ["SubuddyCore"],
            path: "Tests/SubuddyCoreTests"
        )
    ]
)
