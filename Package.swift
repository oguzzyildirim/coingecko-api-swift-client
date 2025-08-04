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
        // Kullanıcıların import edeceği ana product
        .library(
            name: "CoinGeckoSwiftSDK",
            targets: ["CoinGeckoSwiftSDK"]
        ),
    ],
    targets: [
        // Core - Shared components (Configuration, Common models vs.)
        .target(
            name: "CoinGeckoCore",
            path: "Sources/Core",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // Network - Low level networking (Core'a depend eder)
        .target(
            name: "CoinGeckoNetwork",
            dependencies: [.target(name: "CoinGeckoCore")],
            path: "Sources/Network",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // Client - High level API (hem Core hem Network'e depend eder)
        .target(
            name: "CoinGeckoSwiftSDK",
            dependencies: [
                .target(name: "CoinGeckoCore"),
                .target(name: "CoinGeckoNetwork")
            ],
            path: "Sources/Client",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
            ]
        ),
        
        // Tests
        .testTarget(
            name: "CoinGeckoSwiftSDKTests",
            dependencies: ["CoinGeckoSwiftSDK"]
        ),
    ]
)

//// swift-tools-version: 6.1
//import PackageDescription
//
//let package = Package(
//    name: "CoinGeckoSwiftSDK",
//    platforms: [
//        .iOS(.v15),
//        .macOS(.v12),
//        .tvOS(.v15),
//        .watchOS(.v8)
//    ],
//    products: [
//        .library(
//            name: "CoinGeckoSwiftSDK",
//            targets: ["CoinGeckoSwiftSDK"]),
//        .library(
//            name: "CoinGeckoNetwork",
//            targets: ["CoinGeckoNetwork"]),
//    ],
//    targets: [
//        .target(
//            name: "CoinGeckoSwiftSDK",
//            dependencies: [.target(name: "CoinGeckoNetwork")],
//            path: "Sources/Client",
//            swiftSettings: [
//                .enableExperimentalFeature("StrictConcurrency"),
//                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])
//            ]
//        ),
//        .target(
//            name: "CoinGeckoNetwork",
//            path: "Sources/Network",
//            swiftSettings: [
//                .enableExperimentalFeature("StrictConcurrency")
//            ]
//        ),
//        .testTarget(
//            name: "CoinGeckoSwiftSDKTests",
//            dependencies: ["CoinGeckoSwiftSDK"]
//        ),
//    ]
//)

