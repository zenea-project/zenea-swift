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
        
        do {
            var results: Set<Block.ID> = []
            
            let files1 = try await scanDir(url)
            let files2 = try await processIntermediates(files1)
            let files3 = await processIntermediates(files2)
            
            for (previousBytes, file) in files3 {
                guard file.type == .regular else { continue }
                
                guard let bytes = [UInt8](hexString: file.name.string) else { continue }
                guard bytes.count == SHA256.byteCount - previousBytes.count else { continue }
                
                results.insert(Block.ID(algorithm: .sha2_256, hash: previousBytes + bytes))
            }
            
            return .success(results)
        } catch {
            return .failure(.unable)
        }
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

fileprivate func scanDir(_ dir: FilePath) async throws -> AutoClosingDirectoryContents {
    let handle = try await FileSystem.shared.openDirectory(atPath: dir)
    return .init(handle: handle)
}

fileprivate class AutoClosingDirectoryContents: AsyncSequence {
    typealias Element = DirectoryEntry
    
    var handle: DirectoryFileHandle
    
    init(handle: DirectoryFileHandle) {
        self.handle = handle
    }
    
    deinit {
        Task { try? await handle.close() }
    }
    
    func makeAsyncIterator() -> DirectoryEntries.AsyncIterator {
        handle.listContents(recursive: false).makeAsyncIterator()
    }
}

fileprivate func processIntermediate(_ entry: DirectoryEntry, bytes: [UInt8]) async -> ([UInt8], [DirectoryEntry])? {
    guard entry.type == .directory else { return nil }
    
    guard let newBytes = [UInt8](hexString: entry.name.string) else { return nil }
    guard newBytes.count == 1 else { return nil }
    
    var contents: [DirectoryEntry] = []
    do {
        for try await file in try await scanDir(entry.path) {
            contents.append(file)
        }
    } catch {
        return nil
    }
    
    return (bytes + newBytes, contents)
}

fileprivate func processIntermediates<Sequence>(_ entries: Sequence) async throws -> [([UInt8], DirectoryEntry)] where Sequence: AsyncSequence, Sequence.Element == DirectoryEntry {
    var results: [([UInt8], DirectoryEntry)] = []
    
    for try await entry in entries {
        guard let (bytes, subEntries) = await processIntermediate(entry, bytes: []) else { continue }
        
        for subEntry in subEntries {
            results.append((bytes, subEntry))
        }
    }
    
    return results
}

fileprivate func processIntermediates(_ entries: [([UInt8], DirectoryEntry)]) async -> [([UInt8], DirectoryEntry)] {
    var results: [([UInt8], DirectoryEntry)] = []
    
    for (previousBytes, entry) in entries {
        guard let (bytes, subEntries) = await processIntermediate(entry, bytes: []) else { continue }
        
        for subEntry in subEntries {
            results.append((previousBytes + bytes, subEntry))
        }
    }
    
    return results
}
