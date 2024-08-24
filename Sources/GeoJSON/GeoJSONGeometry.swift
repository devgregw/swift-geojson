//
//  GeoJSONGeometry.swift
//
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation

public enum GeoJSONGeometry: Hashable, Sendable {
    case point(GeoJSONPosition)
    case multiPoint([GeoJSONPosition])
    case lineString(GeoJSONLineString)
    case multiLineString([GeoJSONLineString])
    case polygon(GeoJSONPolygon)
    case multiPolygon([GeoJSONPolygon])
}

extension GeoJSONGeometry: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
    
    private func validate(lineString: GeoJSONLineString) throws {
        guard lineString.count >= 2 else {
            throw GeoJSONDecodingError.notEnoughMembers(lineString, got: lineString.count, expected: 2)
        }
    }
    
    private func validateMembers() throws {
        switch self {
        case let .lineString(lineString):
            try validate(lineString: lineString)
        case let .multiLineString(strings):
            try strings.forEach(validate(lineString:))
        default: return
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "Point":
            self = .point(try container.decode(GeoJSONPosition.self, forKey: .coordinates))
        case "MultiPoint":
            self = .multiPoint(try container.decode([GeoJSONPosition].self, forKey: .coordinates))
        case "LineString":
            self = .lineString(try container.decode(GeoJSONLineString.self, forKey: .coordinates))
        case "MultiLineString":
            self = .multiLineString(try container.decode([GeoJSONLineString].self, forKey: .coordinates))
        case "Polygon":
            self = .polygon(try container.decode(GeoJSONPolygon.self, forKey: .coordinates))
        case "MultiPolygon":
            self = .multiPolygon(try container.decode([GeoJSONPolygon].self, forKey: .coordinates))
        default:
            throw GeoJSONDecodingError.unexpectedType(type)
        }
        try self.validateMembers()
    }
}
