# About zenea-swift
This package is a swift library for the [Zenea Project](https://github.com/glasfisch3000/zenea) Data Layer.

It includes the following targets:

### `Zenea`
A base library providing types and protocols.
- [`Block`](Sources/zenea/Block.swift) - an implementation of a Zenea Data Layer block with ID and content.
- [`BlockStorage`](Sources/zenea/BlockStorage.swift) - a protocol for storage systems that can list, check, fetch and put blocks.

### `ZeneaCache`
A very simple block caching system, implemented as a [`BlockStorageWrapper`](Sources/zenea/BlockStorageWrapper.swift).
- [`BlockCache`](Sources/zenea-cache/BlockCache.swift) - a Zenea Block cache.

# How to Use
If you haven't already, download the latest version of Swift, but at least version 5.9.2. On macOS, the recommended way to do this is by downloading the Xcode app. On Linux, you'll want to use [swiftly](https://github.com/swift-server/swiftly).

To use the library targets `Zenea` and `ZeneaCache`, simply include this package in your swift dependencies.

```swift
let package = Package(
    name: "my-example-package",
    platforms: [
        .macOS("13.3")
    ],
    dependencies: [
        .package(url: "https://github.com/zenea-project/zenea-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "my-example-target",
            dependencies: [
                .product(name: "Zenea", package: "zenea-swift")
            ]
        )
    ]
)
```

```swift
import Foundation
import Zenea

let block = Block(content: Data(count: 1))
```

NOTE: This package may not work on systems that do not provide an adequate `Foundation` library. In any recent release of macOS, this should not be a problem. However, on Linux systems you might be using an older version of the library or it might be missing entirely. Apple is currently working on making an [open-source swift version](https://github.com/apple/swift-foundation) of that package that can be used as a dependency on all systems, but as it is still in an early stage, you might run into problems compiling this package.
