// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Channel",
    platforms: [.macOS(.v10_15),
                .iOS(.v13),
                .tvOS(.v13),
                .watchOS(.v6)],
    products: [
        .library(name: "Channel", targets: ["Channel"])
    ],
    targets: [
        .target(name: "Channel", path: "Source"),
        .testTarget(name: "ChannelTests",
                    dependencies: ["Channel"],
                    path: "Tests"),
    ]
)
