//
//  GeoJSONFeature+Properties.swift
//  swift-geojson
//
//  Created by Greg Whatley on 2/28/26.
//

public extension GeoJSONFeature {
    typealias Properties = [String: PropertyValue]

    enum PropertyValue: Decodable, Sendable, Hashable {
        case string(String)
        case number(Double)
        case bool(Bool)
        case array([PropertyValue])
        case object(Properties)
        case null

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
            } else if let doubleValue = try? container.decode(Double.self) {
                self = .number(doubleValue)
            } else if let boolValue = try? container.decode(Bool.self) {
                self = .bool(boolValue)
            } else if let arrayValue = try? container.decode([PropertyValue].self) {
                self = .array(arrayValue)
            } else if let objectValue = try? container.decode([String: PropertyValue].self) {
                self = .object(objectValue)
            } else if container.decodeNil() {
                self = .null
            } else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: container.codingPath,
                    debugDescription: "Failed to decode property value of unknown type",
                    underlyingError: GeoJSONDecodingError.unexpectedType(container.codingPath.debugDescription)
                ))
            }
        }
    }
}

extension GeoJSONFeature.PropertyValue: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByDictionaryLiteral, ExpressibleByFloatLiteral, ExpressibleByArrayLiteral, ExpressibleByBooleanLiteral, ExpressibleByNilLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }

    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }

    public init(dictionaryLiteral elements: (String, Self)...) {
        self = .object(Dictionary(uniqueKeysWithValues: elements))
    }

    public init(floatLiteral value: Double) {
        self = .number(value)
    }

    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }

    public init(arrayLiteral elements: Self...) {
        self = .array(elements)
    }

    public init(nilLiteral: ()) {
        self = .null
    }
}
