import Foundation

enum BlockStorageConditional<TrueContent, FalseContent>: BlockStorage where TrueContent: BlockStorage, FalseContent: BlockStorage {
    case `true`(TrueContent)
    case `false`(FalseContent)
    
    func listBlocks() async -> Result<Set<Block.ID>, Block.ListError> {
        switch self {
        case .true(let trueContent): await trueContent.listBlocks()
        case .false(let falseContent): await falseContent.listBlocks()
        }
    }
    
    func fetchBlock(id: Block.ID) async -> Result<Block, Block.FetchError> {
        switch self {
        case .true(let trueContent): await trueContent.fetchBlock(id: id)
        case .false(let falseContent): await falseContent.fetchBlock(id: id)
        }
    }
    
    func checkBlock(id: Block.ID) async -> Result<Bool, Block.CheckError> {
        switch self {
        case .true(let trueContent): await trueContent.checkBlock(id: id)
        case .false(let falseContent): await falseContent.checkBlock(id: id)
        }
    }
    
    func putBlock(content: Data) async -> Result<Block, Block.PutError> {
        switch self {
        case .true(let trueContent): await trueContent.putBlock(content: content)
        case .false(let falseContent): await falseContent.putBlock(content: content)
        }
    }
    
    var description: String {
        switch self {
        case .true(let trueContent): trueContent.description
        case .false(let falseContent): falseContent.description
        }
    }
}
