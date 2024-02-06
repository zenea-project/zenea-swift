import Foundation
import AsyncHTTPClient
import zenea

public class ZeneaHTTPClient: BlockStorage {
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
        let response = client.get(url: server.construct() + "/block/" + id.description)
        
        do {
            let result = try await response.get()
            
            switch result.status {
            case .ok: break
            case .notFound: return .failure(.notFound)
            default: return .failure(.unable)
            }
            
            guard let body = result.body else { return .failure(.invalidContent) }
            guard let data = body.getData(at: 0, length: body.readableBytes) else { return .failure(.invalidContent) }
            
            let block = Block(content: data)
            guard block.matchesID(id) else { return .failure(.invalidContent) }
            
            return .success(block)
        } catch {
            return .failure(.unable)
        }
    }
    
    public func putBlock(content: Data) async -> Result<Block.ID, BlockPutError> {
        let block = Block(content: content)
        let response = client.post(url: server.construct() + "/block", body: .data(block.content))
        
        do {
            let result = try await response.get()
            
            switch result.status {
            case .ok: break
            case .notFound: return .failure(.exists)
            case .badGateway: return .failure(.unavailable)
            case .forbidden: return .failure(.notPermitted)
            default: return .failure(.unable)
            }
            
            guard let body = result.body else { return .failure(.unable) }
            guard let data = body.getData(at: 0, length: body.readableBytes) else { return .failure(.unable) }
            
            guard let dataString = String(data: data, encoding: .utf8) else { return .failure(.unable) }
            guard let id = Block.ID(parsing: dataString) else { return .failure(.unable) }
            guard block.matchesID(id) else { return .failure(.unable) }
            
            return .success(block.id)
        } catch {
            return .failure(.unavailable)
        }
    }
    
    public func listBlocks() async -> Result<Set<Block.ID>, BlockListError> {
        let response = client.get(url: server.construct() + "/blocks")
        
        do {
            let result = try await response.get()
            
            switch result.status {
            case .ok: break
            case .internalServerError: return .failure(.unable)
            default: return .failure(.unable)
            }
            
            guard let body = result.body else { return .failure(.unable) }
            guard let data = body.getData(at: 0, length: body.readableBytes) else { return .failure(.unable) }
            guard let string = String(data: data, encoding: .utf8) else { return .failure(.unable) }
            
            var results: Set<Block.ID> = []
            
            let values = string.split(separator: ",")
            for value in values {
                guard let id = Block.ID(parsing: String(value)) else { continue }
                results.insert(id)
            }
            
            return .success(results)
        } catch {
            return .failure(.unable)
        }
    }
}

extension ZeneaHTTPClient {
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
            "\(self.scheme)://\(self.address):\(self.port)"
        }
    }
}

extension ZeneaHTTPClient: CustomStringConvertible {
    public var description: String { self.server.description }
}

extension ZeneaHTTPClient.Scheme: CustomStringConvertible {
    public var description: String { self.rawValue }
}

extension ZeneaHTTPClient.Server: CustomStringConvertible {
    public var description: String { self.construct() }
}

extension ZeneaHTTPClient.Scheme: Codable {}
extension ZeneaHTTPClient.Server: Codable {}

extension ZeneaHTTPClient.Server {
    fileprivate static let _serverPattern = try! Regex("(?<scheme>https?)://(?<address>([A-Za-z0-9]+\\.)*[A-Za-z0-9]+|\\[[a-f0-9:]+\\]):(?<port>[0-9]+)")
    
    public init?(parsing string: String) {
        guard let match = string.wholeMatch(of: Self._serverPattern) else { return nil }
        
        guard let schemeSubstring = match["scheme"]?.substring else { return nil }
        guard let scheme = ZeneaHTTPClient.Scheme(rawValue: String(schemeSubstring)) else { return nil }
        self.scheme = scheme
        
        guard let addressSubstring = match["address"]?.substring else { return nil }
        self.address = String(addressSubstring)
        
        guard let portSubstring = match["port"]?.substring else { return nil }
        guard let port = Int(String(portSubstring)) else { return nil }
        self.port = port
    }
}
