// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DirtyMixerApp",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .executable(name: "DirtyMixerApp", targets: ["DirtyMixerApp"])
    ],
    targets: [
        .executableTarget(name: "DirtyMixerApp")
    ]
)
