extension Block {
    /// An error that can occur while listing available blocks.
    public enum ListError: Error {
        case unable
    }
}

extension Block {
    /// An error that can occur while checking a block's availability.
    public enum CheckError: Error {
        case unable
    }
}

extension Block {
    /// An error that can occur while fetching a block.
    public enum FetchError: Error {
        case notFound
        case invalidContent
        case unable
    }
}

extension Block {
    /// An error that can occur while posting a block to a ``BlockStorage``.
    public enum PutError: Error {
        case overflow
        case unavailable
        case notPermitted
        case exists(_ block: Block)
        case unable
    }
}
