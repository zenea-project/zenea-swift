// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "zenea-swift",
    platforms: [
        .macOS("13.3")
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.1"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.2.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.63.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIO", package: "swift-nio"),
                .target(name: "zenea"),
                .target(name: "zenea-fs")
            ]
        ),
        .target(
            name: "zenea-fs",
            dependencies: [
                .target(name: "zenea"),
                .target(name: "utils")
            ]
        ),
        .target(
            name: "zenea",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .target(name: "utils")
            ]
        ),
        .target(
            name: "utils"
        )
    ]
)
