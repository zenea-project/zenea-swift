import Foundation
import Crypto
import utils

public struct Block: Identifiable, Hashable {
    public enum ID: Hashable {
        case sha256(value: [UInt8])
    }
    
    public var id: Self.ID
    public var content: Data
}

fileprivate let _blockIDPattern = try! Regex("(?<algorithm>sha2?-256|sha256)-(?<hash>[A-Fa-f0-9]+)")

extension Block.ID {
    public init?(parsing string: String) {
        guard let match = string.wholeMatch(of: _blockIDPattern) else { return nil }
        
        guard let algorithmSubstring = match["algorithm"]?.substring else { return nil }
        let algorithmString = String(algorithmSubstring)
        
        guard let hashSubstring = match["hash"]?.substring else { return nil }
        let hashString = String(hashSubstring)
        guard let hash = [UInt8](hexString: hashString) else { return nil }
        
        switch algorithmString {
        case "sha2-256", "sha-256", "sha256":
            guard hash.count == SHA256Digest.byteCount else { return nil }
            self = .sha256(value: hash)
        default: return nil
        }
    }
}
