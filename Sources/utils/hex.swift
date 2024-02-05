import Foundation

extension Array where Element == UInt8 {
    public init?(hexString: String) {
        guard hexString.count.isMultiple(of: 2), !hexString.isEmpty else { return nil }
        self.init(repeating: 0, count: hexString.count/2)
        
        let stringBytes: [UInt8] = Array(hexString.data(using: String.Encoding.utf8)!)
        
        for i in stride(from: stringBytes.startIndex, to: stringBytes.endIndex - 1, by: 2) {
            guard let char1 = convertCharToHex(stringBytes[i]) else { return nil }
            guard let char2 = convertCharToHex(stringBytes[i + 1]) else { return nil }
            
            self[i/2] = (char1 & 0xf) << 4 | (char2 & 0xf)
        }
    }
}

extension Collection where Element == UInt8 {
    public func toHexString() -> String {
        return self.reduce(into: "") {
            if let (char1, char2) = convertHexToChars($1) {
                $0 += String(char1) + String(char2)
            }
        }
    }
}

public func convertCharToHex(_ c: UInt8) -> UInt8? {
    switch c {
    case 0x30 ... 0x39: return c - 0x30 // 0-9
    case 0x41 ... 0x46: return c - 0x41 + 0xa // A-F
    case 0x61 ... 0x66: return c - 0x61 + 0xa // a-f
    default: return nil
    }
}

public func convertHexToChars(_ c: UInt8, preferUpperCase: Bool = false) -> (Character, Character)? {
    let c1 = (c >> 4) & 0xf
    let c2 = c & 0xf
    
    let char1: UInt8
    switch c1 {
    case 0x0 ... 0x9: char1 = c1 + 0x30
    case 0xa ... 0xf: char1 = preferUpperCase ? (c1 - 0xa + 0x41) : (c1 - 0xa + 0x61)
    default: return nil
    }
    
    let char2: UInt8
    switch c2 {
    case 0x0 ... 0x9: char2 = c2 + 0x30
    case 0xa ... 0xf: char2 = preferUpperCase ? (c2 - 0xa + 0x41) : (c2 - 0xa + 0x61)
    default: return nil
    }
    
    guard let scalar1 = Unicode.Scalar(UInt32(char1)) else { return nil }
    guard let scalar2 = Unicode.Scalar(UInt32(char2)) else { return nil }
    return (Character(scalar1), Character(scalar2))
}
