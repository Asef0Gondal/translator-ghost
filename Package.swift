// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TranslatorGhost",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TranslatorGhost", targets: ["TranslatorGhost"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "TranslatorGhost",
            dependencies: [],
            path: "Sources"
        )
    ]
)
