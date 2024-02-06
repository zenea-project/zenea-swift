import Foundation

public protocol BlockStorage: CustomStringConvertible {
    func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError>
    @discardableResult func putBlock(content: Data) async -> Result<Block.ID, BlockPutError>
    func listBlocks() async -> Result<Set<Block.ID>, BlockListError>
}
