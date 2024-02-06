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
