import Foundation

public class BlockStorageList: BlockStorage {
    public var sources: [BlockStorage]
    
    public init(sources: [BlockStorage]) {
        self.sources = sources
    }
    
    public var description: String {
        self.sources.description
    }
    
    public func listBlocks() async -> Result<Set<Block.ID>, BlockListError> {
        var result: Set<Block.ID> = []
        
        for source in sources {
            switch await source.listBlocks() {
            case .success(let blocks): result.formUnion(blocks)
            case .failure(_): break
            }
        }
        
        return .success(result)
    }
    
    public func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError> {
        for source in sources {
            switch await source.fetchBlock(id: id) {
            case .success(let block): return .success(block)
            case .failure(_): break
            }
        }
        
        return .failure(.notFound)
    }
    
    public func checkBlock(id: Block.ID) async -> Result<Bool, BlockCheckError> {
        for source in sources {
            switch await source.checkBlock(id: id) {
            case .success(true): return .success(true)
            case .success(false): break
            case .failure(_): break
            }
        }
        
        return .success(false)
    }
    
    public func putBlock(content: Data) async -> Result<Block.ID, BlockPutError> {
        var result: Block.ID? = nil
        
        for source in sources {
            switch await source.putBlock(content: content) {
            case .success(let id): result = id
            case .failure(_): break
            }
        }
        
        guard let result = result else { return .failure(.unable) }
        return .success(result)
    }
}
