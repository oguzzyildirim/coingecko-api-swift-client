// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "CoinGeckoSwiftSDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "CoinGeckoSwiftSDK",
            targets: ["CoinGeckoSwiftSDK"]),
        .library(
            name: "CoinGeckoNetwork",
            targets: ["CoinGeckoNetwork"]),
    ],
    targets: [
        .target(
            name: "CoinGeckoSwiftSDK",
            dependencies: [.target(name: "CoinGeckoNetwork")],
            path: "Sources/Client",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ]
        ),
        .target(
            name: "CoinGeckoNetwork",
            path: "Sources/Network",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "CoinGeckoSwiftSDKTests",
            dependencies: ["CoinGeckoSwiftSDK"]
        ),
    ]
)
