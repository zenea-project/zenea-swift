public protocol BlockStorageWrapper: BlockStorage {
    var name: String { get }
    var source: BlockStorage { get }
}

extension BlockStorageWrapper {
    public var description: String {
        "\(self.name)<\(self.source.description)>"
    }
}
