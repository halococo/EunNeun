// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "EunNeun",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "EunNeun",
            targets: ["EunNeun"]
        ),
    ],
    targets: [
        .target(
            name: "EunNeun"
        ),
        .testTarget(
            name: "EunNeunTests",
            dependencies: ["EunNeun"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
