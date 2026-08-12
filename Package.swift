// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SatellaPolicy",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "SatellaPolicy", targets: ["SatellaPolicy"])
    ],
    targets: [
        .target(name: "SatellaPolicy", path: "Shared"),
        .testTarget(name: "SatellaPolicyTests", dependencies: ["SatellaPolicy"], path: "Tests/SatellaPolicyTests")
    ]
)
