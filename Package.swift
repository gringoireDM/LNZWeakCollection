// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "LNZWeakCollection",
    platforms: [
      .macOS(.v10_10), .iOS(.v10), .tvOS(.v10), .watchOS(.v4)
    ],
    products: [
        .library(
            name: "LNZWeakCollection",
            targets: ["LNZWeakCollection"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LNZWeakCollection",
            dependencies: []),
        .testTarget(
            name: "LNZWeakCollectionTests",
            dependencies: ["LNZWeakCollection"]),
    ]
)
