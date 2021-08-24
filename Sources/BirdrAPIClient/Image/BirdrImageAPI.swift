import Foundation
import Alamofire
import BirdrServiceModel
import BirdrAPIFoundation
import BirdrServiceModel

/// An API that allows creation and reading of images on the birdr platform
public struct BirdrImageAPI {
    public var context: BirdrAPIContext
    
    public typealias SupportedImageType = ImageType
    
    // API constants
    private let image = "image"
    
    private var baseURL: URLBuilder { context.baseServiceURLForCurrentEnvironment }
    private var basePath: [String] {
        return [image]
    }
    private func getURL(additionalPath: [String] = []) -> String {
        var url = baseURL
        url.path = basePath + additionalPath
        return url.urlString
    }
    
    public typealias CreateHandler = (Result<ImageStore.Return, ServiceError>) -> Void
    public typealias ReadHandler = (Result<ImageStore, ServiceError>) -> Void
    
    public init(
        context: BirdrAPIContext = .init()
    ) {
        self.context = context
    }
    
    /// Uploads a new image to the birdr platform
    public func create(
        data: Data,
        type: SupportedImageType? = nil, // Auto if not specified
        named name: String? = nil,
        completionHandler: @escaping CreateHandler
    ) {
        let additionalPath = name.map { [$0] } ?? []
        let url = getURL(additionalPath: additionalPath)
        guard let imageType: SupportedImageType = type ?? .init(fromData: data) else {
            completionHandler(.failure(.imageTypeCouldNotBeDetermined))
            return
        }
        AF.upload(data, to: url, method: .put, headers: [.contentType(imageType.rawValue)])
            .responseDecodable(of: ImageStore.Return.self) { response in
                switch response.result {
                case .success(let imageStoreReturn):
                    return completionHandler(.success(imageStoreReturn))
                case .failure(let error):
                    return completionHandler(.failure(.apiError(error)))
                }
            }
    }
    
    /// Reads a stored image from it's key
    public func read(
        key: String,
        completionHandler: @escaping ReadHandler
    ) {
        AF.request(getURL(additionalPath: [key]), method: .get)
            .responseData { response in
                let headers = response.response?.headers
                let contentType = headers?.value(for: "content-type")
                let contentIDFromHeaders = headers?.value(for: "content-id")
                guard let contentID = contentIDFromHeaders, contentID == key else {
                    completionHandler(.failure(.imageKeysMismatch(expected: key, received: contentIDFromHeaders)))
                    return
                }
                let imageTypeFromHeaders = contentType.flatMap { SupportedImageType(rawValue: $0) }
                let imageName = headers?.value(for: "imageName")
                switch response.result {
                case .success(let data):
                    if let imageType = imageTypeFromHeaders, let uuid = UUID(uuidString: contentID) {
                        completionHandler(.success(
                            ImageStore(
                                uuid: uuid,
                                data: data,
                                type: imageType,
                                withName: imageName
                            )
                        ))
                    } else {
                        if let imageStore = ImageStore(
                            uuidString: contentID,
                            data: data,
                            type: imageTypeFromHeaders,
                            withName: imageName
                        ) {
                            completionHandler(.success(imageStore))
                        } else {
                            completionHandler(.failure(.imageTypeCouldNotBeDetermined))
                        }
                    }
                case .failure(let error):
                    completionHandler(.failure(.apiError(error)))
                }
            }
    }

    public enum ServiceError: Error, CustomStringConvertible {
        case imageTypeCouldNotBeDetermined
        case imageKeysMismatch(expected: String, received: String?)
        case apiError(AFError)
        case otherError(Error)
        
        public var description: String {
            switch self {
            case .imageTypeCouldNotBeDetermined:
                return "The image type for the specified data could not be determined. It may not be a valid or supported image type."
            case .imageKeysMismatch(expected: let expected, received: let received):
                return "The key of the image returned \(received.map { "(\($0)) does not match the expected key (\(expected))" } ?? "does not exist")."
            case .apiError(let error):
                return error.localizedDescription
            case .otherError(let error):
                return error.localizedDescription
            }
        }
    }
}
