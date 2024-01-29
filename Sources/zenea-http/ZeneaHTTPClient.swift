import Vapor
import Foundation
import zenea

public class ZeneaHTTPClient: BlockStorage {
    public enum Scheme: String, Equatable, Hashable {
        case http
        case https
    }
    
    public struct Server: Hashable {
        public var scheme: Scheme
        public var address: String
        public var port: Int
        
        public init(scheme: Scheme, address: String, port: Int) {
            self.scheme = scheme
            self.address = address
            self.port = port
        }
        
        public func construct() -> String {
            "\(self.scheme.rawValue)://\(self.address):\(self.port)"
        }
    }
    
    public var server: Server
    public var client: HTTPClient
    
    public init(_ target: Server, client: HTTPClient) {
        self.server = target
        self.client = client
    }
    
    public init(scheme: Scheme = .https, address: String, port: Int = 4096, client: HTTPClient) {
        self.server = .init(scheme: scheme, address: address, port: port)
        self.client = client
    }
    
    public func fetchBlock(id: Block.ID) async -> Result<Block, BlockFetchError> {
        let response = client.get(url: server.construct() + "/blocks/" + id.description)
        
        do {
            let result = try await response.get()
            
            switch result.status {
            case .ok: break
            case .notFound: return .failure(.notFound)
            default: return .failure(.unable)
            }
            
            guard var body = result.body else { return .failure(.invalidContent) }
            guard let data = body.readData(length: body.readableBytes) else { return .failure(.invalidContent) }
            
            let block = Block(content: data)
            guard block.matchesID(id) else { return .failure(.invalidContent) }
            
            return .success(block)
        } catch {
            return .failure(.unable)
        }
    }
    
    public func putBlock(content: Data) async -> Result<Block.ID, BlockPutError> {
        let block = Block(content: content)
        let response = client.post(url: server.construct() + "/blocks/" + block.id.description)
        
        do {
            let result = try await response.get()
            
            switch result.status {
            case .ok: break
            case .notFound: return .failure(.exists)
            case .badGateway: return .failure(.unavailable)
            case .forbidden: return .failure(.notPermitted)
            default: return .failure(.unable)
            }
            
            guard var body = result.body else { return .failure(.unable) }
            guard let data = body.readData(length: body.readableBytes) else { return .failure(.unable) }
            
            guard let dataString = String(data: data, encoding: .utf8) else { return .failure(.unable) }
            guard let id = Block.ID(parsing: dataString) else { return .failure(.unable) }
            guard block.matchesID(id) else { return .failure(.unable) }
            
            return .success(block.id)
        } catch {
            return .failure(.unavailable)
        }
    }
}
