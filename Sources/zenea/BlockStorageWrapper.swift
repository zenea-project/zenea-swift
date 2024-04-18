public protocol BlockStorageWrapper: BlockStorage {
    associatedtype Source: BlockStorage
    
    static var name: String { get }
    var source: Source { get }
}

extension BlockStorageWrapper {
    public var description: String {
        "\(Self.name)<\(self.source.description)>"
    }
}
