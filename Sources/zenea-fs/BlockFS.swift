import Foundation
import NIOFileSystem
import Crypto
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
    
    public func listBlocks() async -> Result<Set<Block.ID>, BlockListError> {
        var url = zeneaURL
        url.append("blocks")
        
        guard let dir1 = await scanDir(url) else { return .failure(.unable) }
        
        // first level, filter valid entries and expand those
        let files1 = dir1.compactMap { dir -> ([UInt8], DirectoryEntries)? in
            guard dir.type == .directory else { return nil }
            
            guard let byte = [UInt8](hexString: dir.name.string) else { return nil  }
            guard byte.count == 1 else { return nil }
            
            guard let contents = await scanDir(dir.path) else { return nil }
            return (byte, contents)
        }
        
        // second level, same
        let files2 = files1.flatMap { (bytes, files) in
            files.compactMap { dir -> ([UInt8], DirectoryEntries)? in
                guard dir.type == .directory else { return nil }
                
                guard let byte = [UInt8](hexString: dir.name.string) else { return nil }
                guard byte.count == 1 else { return nil }
                
                guard let contents = await scanDir(dir.path) else { return nil }
                return (bytes + byte, contents)
            }
        }
        
        // third level, filter valid files and turn into block ids
        let ids = files2.flatMap { (bytes, files) in
            files.compactMap { dir -> Block.ID? in
                guard dir.type == .regular else { return nil }
                
                guard let decoded = [UInt8](hexString: dir.name.string) else { return nil }
                guard decoded.count == SHA256.byteCount-2 else { return nil }
                
                return Block.ID(algorithm: .sha2_256, hash: bytes+decoded)
            }
        }
        
        var results: Set<Block.ID> = []
        do {
            for try await id in ids {
                results.insert(id)
            }
        } catch {
            print(error)
        }
        
        return .success(results)
    }
    
    public func checkBlock(id: Block.ID) async -> Result<Bool, BlockCheckError> {
        var url = zeneaURL
        url.append("blocks")
        
        let hash = id.hash.toHexString()
        url.append(String(hash[0..<2]))
        url.append(String(hash[2..<4]))
        url.append(String(hash[4...]))
        
        do {
            let info = try await FileSystem.shared.info(forFileAt: url)
            guard let info = info else { return .success(false) }
            
            guard info.type == .regular else { return .failure(.unable) }
            return .success(true)
        } catch let error as FileSystemError where error.code == .notFound {
            return .success(false)
        } catch {
            return .failure(.unable)
        }
    }
    
    public func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError> {
        var url = zeneaURL
        url.append("blocks")
        
        let hash = id.hash.toHexString()
        url.append(String(hash[0..<2]))
        url.append(String(hash[2..<4]))
        url.append(String(hash[4...]))
        
        let handle: ReadFileHandle
        do {
            handle = try await FileSystem.shared.openFile(forReadingAt: url)
        } catch {
            return .failure(.notFound)
        }
        
        defer { Task { try? await handle.close() } }
        
        let fileContent: Data
        do {
            var buffer = try await handle.readToEnd(maximumSizeAllowed: .bytes(1<<16))
            guard let data = buffer.readBytes(length: buffer.readableBytes) else { return .failure(.unable) }
            fileContent = Data(data)
        } catch {
            return .failure(.unable)
        }
        
        let block = Block(content: fileContent)
        guard block.matchesID(id) else { return .failure(.invalidContent) }
        
        return .success(block)
    }
    
    public func putBlock<Bytes>(content: Bytes) async -> Result<Block, BlockPutError> where Bytes: AsyncSequence, Bytes.Element == Data {
        do {
            guard let content = try? await content.read() else { return .failure(.unable) }
            guard content.count <= Block.maxBytes else { return .failure(.overflow) }
            
            let block = Block(content: content)
            
            var url = zeneaURL
            url.append("blocks")
            
            let hash = block.id.hash.toHexString()
            url.append(String(hash[0..<2]))
            url.append(String(hash[2..<4]))
            url.append(String(hash[4...]))
            
            if let info = try await FileSystem.shared.info(forFileAt: url) {
                return .failure(info.type == .regular ? .exists(block) : .unable)
            }
            
            let parent = url.removingLastComponent()
            try? await FileSystem.shared.createDirectory(at: parent, withIntermediateDirectories: true)
            
            let handle = try await FileSystem.shared.openFile(forWritingAt: url, options: .newFile(replaceExisting: false))
            defer { Task { try? await handle.close(makeChangesVisible: true) } }
            
            try await handle.write(contentsOf: block.content, toAbsoluteOffset: 0)
            
            return .success(block)
        } catch {
            return .failure(.unable)
        }
    }
}

extension BlockFS {
    public var description: String { self.zeneaURL.string }
}

fileprivate func scanDir(_ dir: FilePath) async -> DirectoryEntries? {
    do {
        let handle = try await FileSystem.shared.openDirectory(atPath: dir)
        
        let contents = handle.listContents(recursive: false)
        try? await handle.close()
        
        return contents
    } catch {
        return nil
    }
}
