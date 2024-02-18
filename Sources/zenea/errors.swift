public enum BlockListError: Error {
    case unable
}

public enum BlockCheckError: Error {
    case unable
}

public enum BlockFetchError: Error {
    case notFound
    case invalidContent
    case unable
}

public enum BlockPutError: Error {
    case overflow
    case unavailable
    case notPermitted
    case exists
    case unable
}
