import Foundation

/// A combination block storage which wraps two base storages of independent types.
struct BlockStorageTuple<Source1, Source2>: BlockStorage where Source1: BlockStorage, Source2: BlockStorage {
    /// The first of two wrapped source storages.
    public var source1: Source1
    /// The second of two wrapped source storages.
    public var source2: Source2
    
    public var description: String {
        source1.description + ", " + source2.description
    }
    
    public func listBlocks() async -> Result<Set<Block.ID>, Block.ListError> {
        var result: Set<Block.ID> = []
        
        switch await source1.listBlocks() {
        case .success(let blocks): result.formUnion(blocks)
        case .failure(_): break
        }
        
        switch await source2.listBlocks() {
        case .success(let blocks): result.formUnion(blocks)
        case .failure(_): break
        }
        
        return .success(result)
    }
    
    public func fetchBlock(id: Block.ID) async -> Result<Block, Block.FetchError> {
        switch await source1.fetchBlock(id: id) {
        case .success(let block): return .success(block)
        case .failure(_): break
        }
        
        return await source2.fetchBlock(id: id)
    }
    
    public func checkBlock(id: Block.ID) async -> Result<Bool, Block.CheckError> {
        switch await source1.checkBlock(id: id) {
        case .success(true): return .success(true)
        case .success(false): break
        case .failure(_): break
        }
        
        return await source2.checkBlock(id: id)
    }
    
    public func putBlock(content: Data) async -> Result<Block, Block.PutError> {
        var result: Block? = nil
        
        switch await source1.putBlock(content: content) {
        case .success(let block), .failure(.exists(let block)): result = block
        case .failure(_): break
        }
        
        switch await source2.putBlock(content: content) {
        case .success(let block), .failure(.exists(let block)): result = block
        case .failure(_): break
        }
        
        guard let result = result else { return .failure(.unable) }
        return .success(result)
    }
}
