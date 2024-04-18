import Crypto

extension Block {
    public struct ID {
        public enum Algorithm: String {
            case sha2_256 = "sha2-256"
        }
        
        public var algorithm: Algorithm
        public var hash: [UInt8]
        
        public init(algorithm: Algorithm, hash: [UInt8]) {
            self.algorithm = algorithm
            self.hash = hash
        }
    }
}

extension Block.ID: Identifiable, Hashable, Codable {
    public var id: Self { self }
}

extension Block.ID.Algorithm: Hashable, Codable { }

extension Block.ID: CustomStringConvertible {
    fileprivate static let _blockIDPattern = try! Regex("(?<algorithm>sha2?-256|sha256)-(?<hash>[A-Fa-f0-9]+)")
    
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
    
    public var description: String {
        self.algorithm.rawValue + "-" + self.hash.toHexString()
    }
}

extension Block.ID.Algorithm: CustomStringConvertible {
    public init?(parsing string: String) {
        switch string {
        case "sha2-256", "sha2_256", "sha-256", "sha_256", "sha256": self = .sha2_256
        default: return nil
        }
    }
    
    public var description: String {
        self.rawValue
    }
}

extension Block.ID.Algorithm {
    public var bytes: Int {
        switch self {
        case .sha2_256: return 32
        }
    }
}
