import Foundation
import zenea
import utils

public class BlockFS: BlockStorage {
    public var zeneaURL: URL
    
    public init(_ path: URL) {
        self.zeneaURL = path
    }
    
    public func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError> {
        var url = zeneaURL
        url.appendPathComponent("blocks")
        
        let hash = id.hash.toHexString()
        url.appendPathComponent(String(hash[0..<2]))
        url.appendPathComponent(String(hash[2..<4]))
        url.appendPathComponent(String(hash[4...]))
        
        do {
            let (fileContent, _) = try await URLSession.shared.data(from: url)
            
            let block = Block(content: fileContent)
            guard block.matchesID(id) else { return .failure(.invalidContent) }
            
            return .success(block)
        } catch {
            return .failure(.notFound)
        }
    }
    
    public func putBlock(content: Data) async -> BlockPutError? {
        let block = Block(content: content)
        
        var url = zeneaURL
        url.appendPathComponent("blocks")
        
        let hash = block.id.hash.toHexString()
        url.appendPathComponent(String(hash[0..<2]))
        url.appendPathComponent(String(hash[2..<4]))
        url.appendPathComponent(String(hash[4...]))
        
        var isDir: ObjCBool = false
        guard !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) else {
            return isDir.boolValue ? .unable : .exists
        }
        
        let parent = url.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parent.path, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(atPath: parent.path, withIntermediateDirectories: true)
            } catch {
                return .unable
            }
        } else if !isDir.boolValue {
            return .unable
        }
        
        do {
            let handle = try FileHandle(forWritingTo: url)
            try handle.write(contentsOf: block.content)
        } catch {
            return .unable
        }
        
        return nil
    }
}
