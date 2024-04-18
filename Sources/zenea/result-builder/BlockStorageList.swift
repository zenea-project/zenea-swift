import Foundation

struct BlockStorageList<SourceType>: BlockStorage where SourceType: BlockStorage {
    public var sources: [SourceType]
    
    public var description: String {
        sources.map(\.description).joined(separator: ", ")
    }
    
    public func listBlocks() async -> Result<Set<Block.ID>, Block.ListError> {
        var result: Set<Block.ID> = []
        
        for source in sources {
            switch await source.listBlocks() {
            case .success(let blocks): result.formUnion(blocks)
            case .failure(_): break
            }
        }
        
        return .success(result)
    }
    
    public func fetchBlock(id: Block.ID) async -> Result<Block, Block.FetchError> {
        var resultError: Block.FetchError = .notFound
        
        for source in sources {
            switch await source.fetchBlock(id: id) {
            case .success(let block): return .success(block)
            case .failure(let error): resultError = error
            }
        }
        
        return .failure(resultError)
    }
    
    public func checkBlock(id: Block.ID) async -> Result<Bool, Block.CheckError> {
        var resultError: Block.CheckError = .unable
        
        for source in sources {
            switch await source.checkBlock(id: id) {
            case .success(let block): return .success(block)
            case .failure(let error): resultError = error
            }
        }
        
        return .failure(resultError)
    }
    
    public func putBlock<Bytes>(content: Bytes) async -> Result<Block, Block.PutError> where Bytes: AsyncSequence, Bytes.Element == Data {
        var result: Block? = nil
        
        for source in sources {
            switch await source.putBlock(content: content) {
            case .success(let block), .failure(.exists(let block)): result = block
            case .failure(_): break
            }
        }
        
        guard let result = result else { return .failure(.unable) }
        return .success(result)
    }
}
