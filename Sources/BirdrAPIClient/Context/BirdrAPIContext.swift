import Foundation
import BirdrAPIFoundation

public struct BirdrAPIContext: Codable {
    public var environment: ServiceEnvironment = .development
    public var baseServiceURL: EnvironmentValue<URLBuilder>
    
    public var baseServiceURLForCurrentEnvironment: URLBuilder { baseServiceURL.getValue(for: environment) }
    
    public init (
        environment: ServiceEnvironment = .development,
        baseServiceURL: EnvironmentValue<URLBuilder> = .init(all: .localhost)
    ) {
        self.environment = environment
        self.baseServiceURL = baseServiceURL
    }
}
