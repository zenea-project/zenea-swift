import Foundation
import Crypto

/// An implementation of a Zenea Data Layer block that encapsulates binary data in a content-identifiable way.
///
/// A block serves as the basis of Zenea data storage and handling.
/// Each block stores an ID, which is a cryptographic hash of its entire content.
///
/// Create a block using ``init(id:content:)``. If no ID is provided, it will be computed from the given data.
///
/// Blocks can also be retreived from ``BlockStorage`` implementations.
public struct Block {
    public typealias Content = Data
    
    /// A cryptographic hash of the block's content that is used as an identifier.
    public var id: Self.ID
    
    /// The block's wrapped data.
    public var content: Content
    
    /// Create a block with a set of contained data and, optionally, a pre-computed ID. If none is provided, an ID will be created by hashing the given content.
    public init(id: Self.ID? = nil, content: Content) {
        self.content = content
        
        if let id = id {
            self.id = id
        } else {
            var hasher = SHA256()
            hasher.update(data: content)
            
            let hash = hasher.finalize()
            self.id = .init(algorithm: .sha2_256, hash: hash.map { $0 })
        }
    }
    
    /// Re-computes the block's hash value and checks whether it matches the given ID.
    public func matchesID(_ id: ID) -> Bool {
        switch id.algorithm {
        case .sha2_256:
            var hasher = SHA256()
            hasher.update(data: self.content)
            
            let hash = hasher.finalize()
            return id.hash.elementsEqual(hash)
        }
    }
}

extension Block: Identifiable { }
extension Block: Hashable { }
extension Block: Codable { }

extension Block {
    /// The maximum byte size a block should have, as specified by the Zenea Project.
    public static let maxBytes: Int = 1<<16
}
