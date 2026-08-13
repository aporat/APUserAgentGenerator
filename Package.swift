// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "APUserAgentGenerator",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "APUserAgentGenerator",
            targets: ["APUserAgentGenerator"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/devicekit/DeviceKit.git", from: "5.8.0"),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "APUserAgentGenerator",
            dependencies: [
                .product(name: "DeviceKit", package: "DeviceKit"),
                "SwifterSwift"
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "APUserAgentGeneratorTests",
            dependencies: ["APUserAgentGenerator"]
        )
    ]
)
