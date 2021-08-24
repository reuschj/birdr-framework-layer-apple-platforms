import Foundation
import Alamofire

public struct URLBuilder: Codable, CustomStringConvertible {
    public var `protocol`: URLProtocol = .https
    public var host: String
    public var port: Int? = nil
    public var path: [String] = []
    
    public init(
        _ urlProtocol: URLProtocol = .https,
        host: String,
        port: Int? = nil,
        path: [String] = []
    ) {
        self.protocol = urlProtocol
        self.host = host
        self.port = port
        self.path = path
    }
    
    private var fullPath: String {
        path.compactMap {
            $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        }.joined(separator: "/")
    }
    
    public var urlString: String {
        "\(self.protocol)://\(host)\(port.map { ":\($0)" } ?? "")/\(fullPath)"
    }
    
    public var url: URL? {
        URL(string: urlString)
    }
    
    public var description: String { urlString }
    
    public enum URLProtocol: String, RawRepresentable, Codable, CustomStringConvertible {
        case http
        case https
        case ftp
        
        public var description: String { rawValue }
    }
    
    public static let localhost: URLBuilder = .init(.http, host: "localhost", port: 8080)
}
