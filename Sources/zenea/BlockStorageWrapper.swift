public protocol BlockStorageWrapper: BlockStorage {
    static var name: String { get }
    var source: BlockStorage { get }
}

extension BlockStorageWrapper {
    public var description: String {
        "\(Self.name)<\(self.source.description)>"
    }
}
