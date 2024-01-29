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
    
    public func putBlock(content: Data) async -> Result<Block.ID, BlockPutError> {
        let block = Block(content: content)
        
        var url = zeneaURL
        url.append("blocks")
        
        let hash = block.id.hash.toHexString()
        url.append(String(hash[0..<2]))
        url.append(String(hash[2..<4]))
        url.append(String(hash[4...]))
        
        var isDir: ObjCBool = false
        guard !FileManager.default.fileExists(atPath: url.string, isDirectory: &isDir) else {
            return isDir.boolValue ? .failure(.unable) : .failure(.exists)
        }
        
        let parent = url.removingLastComponent()
        if !FileManager.default.fileExists(atPath: parent.string, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(atPath: parent.string, withIntermediateDirectories: true)
            } catch {
                return .failure(.unable)
            }
        } else if !isDir.boolValue {
            return .failure(.unable)
        }
        
        do {
            let handle = try await FileSystem.shared.openFile(forWritingAt: url, options: .newFile(replaceExisting: false))
            defer { Task { try? await handle.close() } }
            
            try await handle.write(contentsOf: block.content, toAbsoluteOffset: 0)
        } catch {
            return .failure(.unable)
        }
        
        return .success(block.id)
    }
    
    public func listBlocks() async -> Result<Set<Block.ID>, BlockListError> {
        var url = zeneaURL
        url.append("blocks")
        
        var blocks: Set<Block.ID> = []
        
        guard let files1 = await scanDir(url) else { return .failure(.unable) }
        
        do {
            for try await file1 in files1 {
                guard file1.type == .directory else { continue }
                
                guard let decoded1 = [UInt8](hexString: file1.name.string) else { continue }
                guard decoded1.count == 1 else { continue }
                
                guard let files2 = await scanDir(file1.path) else { continue }
                
                do {
                    for try await file2 in files2 {
                        guard file2.type == .directory else { continue }
                        
                        guard let decoded2 = [UInt8](hexString: file2.name.string) else { continue }
                        guard decoded2.count == 1 else { continue }
                        
                        guard let files3 = await scanDir(file2.path) else { continue }
                        
                        do {
                            for try await file3 in files3 {
                                guard file3.type == .regular else { continue }
                                
                                guard let decoded3 = [UInt8](hexString: file3.name.string) else { continue }
                                guard decoded3.count == SHA256.Digest.byteCount-2 else { continue }
                                
                                let id = Block.ID(algorithm: .sha2_256, hash: decoded1+decoded2+decoded3)
                                blocks.insert(id)
                            }
                        } catch {}
                    }
                } catch {}
            }
        } catch {}
        
        return .success(blocks)
    }
    
    private func scanDir(_ dir: FilePath) async -> DirectoryEntries? {
        let handle: DirectoryFileHandle
        
        do {
            handle = try await FileSystem.shared.openDirectory(atPath: dir)
        } catch {
            return nil
        }
        
        defer { Task { try? await handle.close() } }
        
        return handle.listContents(recursive: false)
    }
}
