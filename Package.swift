// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "mac-language-change",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "mac-language-change",
            targets: ["mac-language-change"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "mac-language-change",
            dependencies: []
        ),
    ]
)

