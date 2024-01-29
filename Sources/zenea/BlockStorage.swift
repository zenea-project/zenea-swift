import Foundation

public protocol BlockStorage {
    func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError>
    func putBlock(content: Data) async -> BlockPutError?
}

public enum BlockFetchError: Error {
    case notFound
    case invalidContent
}

public enum BlockPutError: Error {
    case unavailable
    case notPermitted
    case exists
    case unable
}
