// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "APUserAgentGenerator",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v17),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "APUserAgentGenerator",
            targets: ["APUserAgentGenerator"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/devicekit/DeviceKit.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "APUserAgentGenerator",
            dependencies: [
                "DeviceKit"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "APUserAgentGeneratorTests",
            dependencies: ["APUserAgentGenerator"],
            path: "Tests"
        )
    ]
)
