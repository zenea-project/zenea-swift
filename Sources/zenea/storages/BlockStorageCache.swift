import Foundation

public class BlockStorageCache: BlockStorageWrapper {
    public static var name: String { "cache" }
    
    public var source: BlockStorage
    
    private var list: Set<Block.ID>
    private var cache: [Block.ID: Block]
    
    public init(source: BlockStorage) {
        self.source = source
        self.list = []
        self.cache = [:]
    }
    
    public func listBlocks() -> Result<Set<Block.ID>, BlockListError> {
        return .success(self.list)
    }
    
    public func updateList() async -> Result<(), BlockListError> {
        switch await self.source.listBlocks() {
        case .success(let blocks): 
            self.list = blocks
            self.cache = self.cache.filter { blocks.contains($0.key) }
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func checkBlock(id: Block.ID) async -> Result<Bool, BlockCheckError> {
        if self.list.contains(id) { return .success(true) }
        
        switch await self.source.checkBlock(id: id) {
        case .success(let check):
            if check { self.list.insert(id) }
            return .success(check)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError> {
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
    
    public func putBlock(content: Data) async -> Result<Block.ID, BlockPutError> {
        let block = Block(content: content)
        
        switch await self.source.putBlock(content: content) {
        case .success(let id):
            self.list.insert(id)
            self.cache[id] = block
            return .success(id)
        case .failure(let error):
            return .failure(error)
        }
    }
}
