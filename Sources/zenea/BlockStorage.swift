import Foundation

public protocol BlockStorage {
    func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError>
    func putBlock(content: Data) async -> Result<Block.ID, BlockPutError>
    func listBlocks() async -> Result<Set<Block.ID>, BlockListError>
}

public enum BlockFetchError: Error {
    case notFound
    case unable
    case invalidContent
}

public enum BlockPutError: Error {
    case unavailable
    case notPermitted
    case exists
    case unable
}

public enum BlockListError: Error {
    case unable
}
