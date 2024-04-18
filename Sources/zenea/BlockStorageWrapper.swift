/// A protocol for block storages that wrap another storage with additional functionality.
public protocol BlockStorageWrapper: BlockStorage {
    /// The wrapped storage type.
    associatedtype Source: BlockStorage
    
    /// A textual representation specifically of this wrapper, not regarding the wrapped storage.
    var name: String { get }
    
    /// The wrapped block storage.
    var source: Source { get }
}

extension BlockStorageWrapper {
    public var description: String {
        "\(self.name)<\(self.source.description)>"
    }
}
