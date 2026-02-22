// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// VINScoutTester is a Windows/Linux CLI tool that uses a Task + DispatchSemaphore
// pattern to work around missing @main async support on those platforms.
// It does not build cleanly on macOS/arm64, so we exclude it there.
#if os(macOS)
let extraProducts: [Product] = []
let extraTargets: [Target] = []
#else
let extraProducts: [Product] = [
    .executable(name: "VINScoutTester", targets: ["VINScoutTester"])
]
let extraTargets: [Target] = [
    .executableTarget(
        name: "VINScoutTester",
        dependencies: ["VINScoutEngine"],
        path: "Sources/VINScoutTester"
    )
]
#endif

let package = Package(
    name: "VINScoutEngine",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "VINScoutEngine",
            targets: ["VINScoutEngine"]
        ),
    ] + extraProducts,
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
    ] + extraTargets
)
