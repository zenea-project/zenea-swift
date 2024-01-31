# About zenea-swift
This package is a swift implementation of the [Zenea Project](https://github.com/glasfisch3000/zenea) Data Layer.

It includes the following targets:
### `zenea`
A base library providing types and protocols.
- [`Block`](Sources/zenea/Block.swift) - an implementation of a Zenea Data Layer block with ID and content.
- [`BlockStorage`](Sources/zenea/BlockStorage.swift) - a protocol for storage systems that can list, fetch or put blocks.
### `zenea-fs`
A local-file-based block storage system, built on [swift-nio's](https://github.com/apple/swift-nio) `NIOFileSystem`.
- [`BlockFS`](Sources/zenea-fs/BlockFS.swift) - a file system implementation of the `BlockStorage` protocol.
### `zenea-http`
An HTTP client for a web-based block storage system, built on [vapor](https://github.com/vapor/vapor).
- [`ZeneaHTTPClient`](Sources/zenea-http/ZeneaHTTPClient.swift) - an HTTP client implementation of the `BlockStorage` protocol.
### `App`
An executable web server application, providing web access to a local block storage. It is built on [vapor](https://github.com/vapor/vapor) and utilises `BlockFS`.
- [`configure(_:)`](Sources/App/configure.swift) - configures an `Application` object to serve HTTP requests.
- [`Entrypoint`](Sources/App/entrypoint.swift) - provides a starting point for the Vapor app life cycle.
# How to Use
Download the latest version of Swift, but at least version 5.9.2. On macOS, the recommended way to do this is by downloading the Xcode app. On Linux, you'll want to use [swiftly](https://github.com/swift-server/swiftly).

You'll be able to import and use the library targets `zenea`, `zenea-fs` and `zenea-http` simply by including this package in your swift dependencies.

To run the web server provided by the `App` target, `cd` into whatever directory this readme file is in and execute `swift run`.