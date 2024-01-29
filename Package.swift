// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "zenea-swift",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
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
