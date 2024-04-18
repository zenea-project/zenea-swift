// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "zenea-swift",
    platforms: [
        .macOS("13.3")
    ],
    products: [
        .library(name: "zenea-swift", targets: ["Zenea", "ZeneaCache"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.3.0") 
    ],
    targets: [
        .target(
            name: "Zenea",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto")
            ],
            path: "./Sources/zenea"
        ),
        .target(
            name: "ZeneaCache",
            dependencies: [
                .target(name: "Zenea")
            ],
            path: "./Sources/zenea-cache"
        )
    ]
)
