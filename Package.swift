// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "APUserAgentGenerator",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "APUserAgentGenerator",
            targets: ["APUserAgentGenerator"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/devicekit/DeviceKit.git", from: "5.8.0")
    ],
    targets: [
        .target(
            name: "APUserAgentGenerator",
            dependencies: [
                // DeviceKit does not support macOS, and only the app-side
                // builder needs it. The browser builders are pure string work.
                .product(
                    name: "DeviceKit",
                    package: "DeviceKit",
                    condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])
                )
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
