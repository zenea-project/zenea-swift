import NIOFileSystem
import Foundation
import zenea
import utils

public class BlockFS: BlockStorage {
    public var zeneaURL: FilePath
    
    public init(_ path: String) {
        self.zeneaURL = FilePath(path)
    }
    
    public init(_ path: FilePath) {
        self.zeneaURL = path
    }
    
    public func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError> {
        var url = zeneaURL
        url.append("blocks")
        
        let hash = id.hash.toHexString()
        url.append(String(hash[0..<2]))
        url.append(String(hash[2..<4]))
        url.append(String(hash[4...]))
        
        print(url)
        
        do {
            let handle = try await FileSystem.shared.openFile(forReadingAt: url)
            defer { Task { try? await handle.close() } }
            
            var buffer = try await handle.readToEnd(maximumSizeAllowed: .bytes(1<<16))
            guard let data = buffer.readBytes(length: buffer.readableBytes) else { return .failure(.notFound) }
            
            let block = Block(content: Data(data))
            guard block.matchesID(id) else { return .failure(.invalidContent) }
            
            return .success(block)
        } catch {
            print(error)
            return .failure(.notFound)
        }
    }
    
    public func putBlock(content: Data) async -> BlockPutError? {
        let block = Block(content: content)
        
        var url = zeneaURL
        url.append("blocks")
        
        let hash = block.id.hash.toHexString()
        url.append(String(hash[0..<2]))
        url.append(String(hash[2..<4]))
        url.append(String(hash[4...]))
        
        var isDir: ObjCBool = false
        guard !FileManager.default.fileExists(atPath: url.string, isDirectory: &isDir) else {
            return isDir.boolValue ? .unable : .exists
        }
        
        let parent = url.removingLastComponent()
        if !FileManager.default.fileExists(atPath: parent.string, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(atPath: parent.string, withIntermediateDirectories: true)
            } catch {
                return .unable
            }
        } else if !isDir.boolValue {
            return .unable
        }
        
        do {
            let handle = try await FileSystem.shared.openFile(forWritingAt: url, options: .newFile(replaceExisting: false))
            defer { Task { try? await handle.close() } }
            
            try await handle.write(contentsOf: block.content, toAbsoluteOffset: 0)
        } catch {
            return .unable
        }
        
        return nil
    }
}
