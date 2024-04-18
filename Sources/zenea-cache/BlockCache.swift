import Foundation
import Zenea

public class BlockCache<Source>: BlockStorageWrapper where Source: BlockStorage {
    public var name: String { "cache" }
    
    public var source: Source
    
    private var list: Set<Block.ID>
    private var cache: [Block.ID: Block]
    
    public init(source: Source) {
        self.source = source
        self.list = []
        self.cache = [:]
    }
    
    public init(@BlockStorageBuilder sources: () -> Source) {
        self.source = sources()
        self.list = []
        self.cache = [:]
    }
    
    public func listBlocks() -> Result<Set<Block.ID>, Block.ListError> {
        return .success(self.list)
    }
    
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
    
    public func putBlock<Bytes>(content: Bytes) async -> Result<Block, Block.PutError> where Bytes: AsyncSequence, Bytes.Element == Data {
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
