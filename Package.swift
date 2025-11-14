// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacLanguageChager",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MacLanguageChager",
            targets: ["MacLanguageChager"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "MacLanguageChager",
            dependencies: []
        ),
    ]
)

