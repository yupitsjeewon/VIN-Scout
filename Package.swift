// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VINScoutEngine",
    platforms: [
        .iOS(.v16),
        .macOS(.v13) // Required for Windows/Linux builds and testing
    ],
    products: [
        .library(
            name: "VINScoutEngine",
            targets: ["VINScoutEngine"]
        ),
        .executable(
            name: "VINScoutTester",
            targets: ["VINScoutTester"]
        )
    ],
    targets: [
        // MARK: - Core Library
        .target(
            name: "VINScoutEngine",
            dependencies: [],
            path: "Sources/VINScoutEngine"
        ),
        // MARK: - Unit Tests
        .testTarget(
            name: "VINScoutEngineTests",
            dependencies: ["VINScoutEngine"],
            path: "Tests/VINScoutEngineTests"
        ),
        // MARK: - CLI Tester (swift run VINScoutTester <VIN>)
        .executableTarget(
            name: "VINScoutTester",
            dependencies: ["VINScoutEngine"],
            path: "Sources/VINScoutTester"
        )
    ]
)
