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
    targets: [
        // No dependencies: the browser side is pure string work, and the app
        // side reads Bundle / ProcessInfo / uname, all of which are available
        // on every Apple platform and on Linux.
        .target(
            name: "APUserAgentGenerator",
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
