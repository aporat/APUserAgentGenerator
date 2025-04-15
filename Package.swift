// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "APUserAgentGenerator",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "APUserAgentGenerator",
            targets: ["APUserAgentGenerator"]
        ),
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
        ),
    ],
    swiftLanguageVersions: [.v5]
)
