extension Block {
    public enum ListError: Error {
        case unable
    }
}

extension Block {
    public enum CheckError: Error {
        case unable
    }
}

extension Block {
    public enum FetchError: Error {
        case notFound
        case invalidContent
        case unable
    }
}

extension Block {
    public enum PutError: Error {
        case overflow
        case unavailable
        case notPermitted
        case exists(_ block: Block)
        case unable
    }
}
