import Crypto

extension Block {
    /// A cryptographic hash of a ``Block``'s content.
    public struct ID {
        /// A set of cryptographic hashing algorithms as specified by Zenea Project.
        /// Currently only supports SHA2-256.
        public enum Algorithm: String {
            /// The 256-bit version of the [SHA-2](https://wikipedia.org/wiki/SHA-2) algorithm family.
            case sha2_256 = "sha2-256"
        }
        
        /// The hashing algorithm used to created this block ID.
        public var algorithm: Algorithm
        
        /// The block ID's raw hash value.
        public var hash: [UInt8]
        
        /// Create a block ID with a given hashing algorithm and hash data.
        public init(algorithm: Algorithm, hash: [UInt8]) {
            self.algorithm = algorithm
            self.hash = hash
        }
    }
}

extension Block.ID: Hashable { }
extension Block.ID: Codable { }
extension Block.ID: Identifiable {
    public var id: Self { self }
}

extension Block.ID.Algorithm: Hashable { }
extension Block.ID.Algorithm: Codable { }

extension Block.ID: CustomStringConvertible {
    fileprivate static let _blockIDPattern = try! Regex("(?<algorithm>sha2?-256|sha256)-(?<hash>[A-Fa-f0-9]+)")
    
    /// Create a block ID by parsing the algorithm and hash data from a hexadecimal string.
    public init?(parsing string: String) {
        guard let match = string.wholeMatch(of: Self._blockIDPattern) else { return nil }
        
        guard let algorithmSubstring = match["algorithm"]?.substring else { return nil }
        guard let algorithm = Algorithm(parsing: String(algorithmSubstring)) else { return nil }
        self.algorithm = algorithm
        
        guard let hashSubstring = match["hash"]?.substring else { return nil }
        guard let hash = [UInt8](hexString: String(hashSubstring)) else { return nil }
        self.hash = hash
        
        switch algorithm {
        case .sha2_256: if hash.count != SHA256.Digest.byteCount { return nil }
        }
    }
    
    /// A parsable hexadecimal representation of the block ID algorithm and hash value.
    public var description: String {
        self.algorithm.rawValue + "-" + self.hash.toHexString()
    }
}

extension Block.ID.Algorithm: CustomStringConvertible {
    /// Create an algorithm by parsing an identifier string.
    public init?(parsing string: String) {
        switch string {
        case "sha2-256", "sha2_256", "sha-256", "sha_256", "sha256": self = .sha2_256
        default: return nil
        }
    }
    
    /// A parsable identifier of the algorithm.
    public var description: String {
        self.rawValue
    }
}

extension Block.ID.Algorithm {
    /// The intended byte length of the associated hash data.
    public var byteCount: Int {
        switch self {
        case .sha2_256: return 32
        }
    }
}
