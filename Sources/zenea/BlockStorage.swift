import Foundation

/// An interface for Zenea block storage systems that supports storing and reading block data.
public protocol BlockStorage: CustomStringConvertible {
    /// Lists all blocks that are available for fetching from this storage.
    func listBlocks() async -> Result<Set<Block.ID>, Block.ListError>
    
    /// Searches the storage for a given block ID and returns the associated content.
    func fetchBlock(id: Block.ID) async -> Result<Block, Block.FetchError>
    
    /// Checks whether a given block can be fetched from the storage.
    func checkBlock(id: Block.ID) async -> Result<Bool, Block.CheckError>
    
    /// Stores a given data set as a new block in the storage.
    @discardableResult
    func putBlock<Bytes>(content: Bytes) async -> Result<Block, Block.PutError> where Bytes: AsyncSequence, Bytes.Element == Data
}

extension BlockStorage {
    public func putBlock(data: Data) async -> Result<Block, Block.PutError> {
        await self.putBlock(content: [data])
    }
    
    public func putBlock(block: Block) async -> Result<Block, Block.PutError> {
        await self.putBlock(content: [block.content])
    }
}
