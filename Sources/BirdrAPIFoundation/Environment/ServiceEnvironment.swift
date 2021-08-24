import Foundation

public enum ServiceEnvironment: String, RawRepresentable, Codable, Hashable {
    case development = "DEV"
    case qualityAssurance = "QA"
    case staging = "STG"
    case production = "PROD"
}

extension ServiceEnvironment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .development:
            return "Development"
        case .qualityAssurance:
            return "Quality Assurance"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        }
    }
}

extension ServiceEnvironment: Comparable, Equatable {
    private var value: Int {
        switch self {
        case .development:
            return 1
        case .qualityAssurance:
            return 2
        case .staging:
            return 3
        case .production:
            return 4
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}
