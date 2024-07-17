import Foundation
import Zenea

/// A block storage wrapper that adds basic caching functionality.
public actor BlockCache<Source>: BlockStorageWrapper where Source: BlockStorage {
    public nonisolated var name: String { "cache" }
    
    public let source: Source
    
    /// A hashed index of all the blocks IDs that are known to this cache.
    private var list: Set<Block.ID>
    
    /// The underlying cache storage.
    private var cache: [Block.ID: Block]
    
    /// Create a block cache instance from a source storage.
    public init(source: Source) {
        self.source = source
        self.list = []
        self.cache = [:]
    }
    
    /// Create a block cache instance from a ``BlockStorageBuilder`` source.
    public init(@BlockStorageBuilder sources: () -> Source) {
        self.source = sources()
        self.list = []
        self.cache = [:]
    }
    
    public func listBlocks() -> Result<Set<Block.ID>, Block.ListError> {
        return .success(self.list)
    }
    
    /// Updates the cache's block index.
    public func updateList() async -> Result<(), Block.ListError> {
        switch await self.source.listBlocks() {
        case .success(let blocks):
            self.list = blocks
            self.cache = self.cache.filter { blocks.contains($0.key) }
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func checkBlock(id: Block.ID) async -> Result<Bool, Block.CheckError> {
        if self.list.contains(id) { return .success(true) }
        
        switch await self.source.checkBlock(id: id) {
        case .success(let check):
            if check { self.list.insert(id) }
            return .success(check)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func fetchBlock(id: Block.ID) async -> Result<Block, Block.FetchError> {
        if let block = self.cache[id] { return .success(block) }
        
        switch await self.source.fetchBlock(id: id) {
        case .success(let block):
            self.list.insert(block.id)
            self.cache[block.id] = block
            return .success(block)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func putBlock(content: Data) async -> Result<Block, Block.PutError> {
        switch await self.source.putBlock(content: content) {
        case .success(let block):
            self.list.insert(block.id)
            self.cache[block.id] = block
            return .success(block)
        case .failure(.exists(let block)):
            self.list.insert(block.id)
            self.cache[block.id] = block
            return .failure(.exists(block))
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension BlockCache: Sendable where Source: Sendable { }
