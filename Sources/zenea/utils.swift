import Foundation

extension AsyncSequence where Element == Data {
    public func read() async throws -> Data {
        var data = Data()
        for try await subdata in self {
            data += subdata
        }
        
        return data
    }
}

extension AsyncSequence where Self: Sequence, Iterator: AsyncIteratorProtocol {
    public func makeAsyncIterator() -> Iterator {
        self.makeIterator()
    }
}

extension Array: AsyncSequence { }
extension ArraySlice: AsyncSequence { }
extension IndexingIterator: AsyncIteratorProtocol { }
