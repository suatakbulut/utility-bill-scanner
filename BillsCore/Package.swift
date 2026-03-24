 // swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BillsCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "BillsCore", targets: ["BillsCore"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "BillsCore"),
        .testTarget(name: "BillsCoreTests", dependencies: ["BillsCore"]),
    ]
)
