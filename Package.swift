// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "zenea-swift",
    platforms: [
        .macOS("13.3")
    ],
    products: [
        .library(name: "zenea", targets: ["zenea", "zenea-fs", "zenea-http"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.1"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.2.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.63.0")
    ],
    targets: [
        .target(
            name: "zenea-fs",
            dependencies: [
                .product(name: "_NIOFileSystem", package: "swift-nio"),
                .target(name: "zenea"),
                .target(name: "utils")
            ]
        ),
        .target(
            name: "zenea-http",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Crypto", package: "swift-crypto"),
                .target(name: "zenea")
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
