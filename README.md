# About zenea-swift
This package is a swift library for the [Zenea Project](https://github.com/glasfisch3000/zenea) Data Layer.

It includes the following targets:

### `zenea`
A base library providing types and protocols.
- [`Block`](Sources/zenea/Block.swift) - an implementation of a Zenea Data Layer block with ID and content.
- [`BlockStorage`](Sources/zenea/BlockStorage.swift) - a protocol for storage systems that can list, fetch or put blocks.

### `zenea-fs`
A local-file-based block storage system, built on [swift-nio's](https://github.com/apple/swift-nio) `NIOFileSystem`.
- [`BlockFS`](Sources/zenea-fs/BlockFS.swift) - a file system implementation of the `BlockStorage` protocol.

### `zenea-http`
An HTTP client for a web-based block storage system, built on [async-http-client](https://github.com/swift-server/async-http-client).
- [`ZeneaHTTPClient`](Sources/zenea-http/ZeneaHTTPClient.swift) - an HTTP client implementation of the `BlockStorage` protocol.

# How to Use
If you haven't already, download the latest version of Swift, but at least version 5.9.2. On macOS, the recommended way to do this is by downloading the Xcode app. On Linux, you'll want to use [swiftly](https://github.com/swift-server/swiftly).

To use the library targets `zenea`, `zenea-fs` and `zenea-http`, simply include this package in your swift dependencies.

NOTE: This package may not work on systems that do not provide an adequate `Foundation` library. In any recent release of macOS, this should not be a problem. However, on Linux systems you might be using an older version of the library or it might be missing entirely. Apple is currently working on making an [open-source swift version](https://github.com/apple/swift-foundation) of that package that can be used as a dependency on all systems, but as it is still in an early stage, you could run into problems compiling this package.
