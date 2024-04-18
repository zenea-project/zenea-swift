import Foundation
import Crypto

public struct Block {
    public typealias Content = Data
    
    public var id: Self.ID
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
    public static let maxBytes: Int = 1<<16
}
