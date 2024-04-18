import Foundation

extension AsyncSequence where Self: Sequence, Iterator: AsyncIteratorProtocol {
    public func makeAsyncIterator() -> Iterator {
        self.makeIterator()
    }
}

extension Array: AsyncSequence { }
extension ArraySlice: AsyncSequence { }
extension IndexingIterator: AsyncIteratorProtocol { }
