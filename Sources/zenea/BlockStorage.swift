import Vapor
import Foundation

public protocol BlockStorage: CustomStringConvertible {
    func listBlocks() async -> Result<Set<Block.ID>, BlockListError>
    
    func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError>
    
    func checkBlock(id: Block.ID) async -> Result<Bool, BlockCheckError>
    
    @discardableResult
    func putBlock<Bytes>(content: Bytes) async -> Result<Block, BlockPutError> where Bytes: AsyncSequence, Bytes.Element == Data
}
