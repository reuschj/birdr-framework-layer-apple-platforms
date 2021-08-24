import Foundation

/// Can simultaneously hold values for different service environments.
public struct EnvironmentValue<Value> {
    public var development: Value
    public var qualityAssurance: Value
    public var staging: Value
    public var production: Value
    
    public init(
        development: Value,
        qualityAssurance: Value,
        staging: Value,
        production: Value
    ) {
        self.development = development
        self.qualityAssurance = qualityAssurance
        self.staging = staging
        self.production = production
    }
    
    public init(
        all universal: Value
    ) {
        self.init(development: universal, qualityAssurance: universal, staging: universal, production: universal)
    }
    
    public init(
        defaultValue: Value,
        development: Value?,
        qualityAssurance: Value?,
        staging: Value?,
        production: Value?
    ) {
        self.init(
            development: development ?? defaultValue,
            qualityAssurance: qualityAssurance ?? defaultValue,
            staging: staging ?? defaultValue,
            production: production ?? defaultValue
        )
    }
    
    public subscript (environment: ServiceEnvironment) -> Value {
        get { getValue(for: environment) }
        set { set(value: newValue, for: environment) }
    }
    
    public func getValue(for environment: ServiceEnvironment) -> Value {
        switch environment {
        case .development:
            return development
        case .qualityAssurance:
            return qualityAssurance
        case .staging:
            return staging
        case .production:
            return production
        }
    }
    
    public mutating func set(value: Value, for environment: ServiceEnvironment) -> Void {
        switch environment {
        case .development:
            development = value
        case .qualityAssurance:
            qualityAssurance = value
        case .staging:
            staging = value
        case .production:
            production = value
        }
    }
}

extension EnvironmentValue: Codable where Value: Codable {}
