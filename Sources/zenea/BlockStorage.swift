import Foundation

public protocol BlockStorage: CustomStringConvertible {
    func listBlocks() async -> Result<Set<Block.ID>, Block.ListError>
    
    func fetchBlock(id: Block.ID) async -> Result<Block, Block.FetchError>
    
    func checkBlock(id: Block.ID) async -> Result<Bool, Block.CheckError>
    
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
