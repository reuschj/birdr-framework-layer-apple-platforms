import Foundation
import Alamofire
import BirdrAPIFoundation
import BirdrModel
import BirdrFoundation

/// An API that allows creation and reading of bird spottings on the birdr platform
public struct BirdrSpottingAPI {
    public var context: BirdrAPIContext
    
    // API constants
    private let spotting = "spotting"
    
    private var baseURL: URLBuilder { context.baseServiceURLForCurrentEnvironment }
    private var basePath: [String] {
        return [spotting]
    }
    private func getURL(additionalPath: [String] = []) -> String {
        var url = baseURL
        url.path = basePath + additionalPath
        return url.urlString
    }
    
    public typealias CreateHandler = (Result<BirdSpotting.Return, ServiceError>) -> Void
    public typealias ReadHandler = (Result<BirdSpotting, ServiceError>) -> Void
    
    public init(
        context: BirdrAPIContext = .init()
    ) {
        self.context = context
    }
    
    /// Uploads a new image to the birdr platform
    public func create(
        with birdSpotting: BirdSpotting,
        completionHandler: @escaping CreateHandler
    ) {
        AF.request(getURL(),
                   method: .post,
                   parameters: birdSpotting,
                   encoder: JSONParameterEncoder.prettyPrinted
        )
            .responseDecodable(of: BirdSpotting.Return.self) { response in
                switch response.result {
                case .success(let birdSpottingReturn):
                    completionHandler(.success(birdSpottingReturn))
                case .failure(let error):
                    completionHandler(.failure(.apiError(error)))
                }
            }
    }
    
    /// Reads a stored image from it's key
    public func read(
        key: String,
        completionHandler: @escaping ReadHandler
    ) {
        AF.request(getURL(additionalPath: [key]), method: .get)
            .responseDecodable(of: BirdSpotting.self) { response in
                switch response.result {
                case .success(let birdSpotting):
                    completionHandler(.success(birdSpotting))
                case .failure(let error):
                    completionHandler(.failure(.apiError(error)))
                }
            }
    }
    
    public enum ServiceError: Error, CustomStringConvertible {
        case apiError(AFError)
        case otherError(Error)
        
        public var description: String {
            switch self {
            case .apiError(let error):
                return error.localizedDescription
            case .otherError(let error):
                return error.localizedDescription
            }
        }
    }
}
