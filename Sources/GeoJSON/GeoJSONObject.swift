//
//  GeoJSONObject.swift
//
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation

public enum GeoJSONObject: Hashable, Sendable {
    case featureCollection([GeoJSONFeature])
    case feature(GeoJSONFeature)
    case geometry(GeoJSONGeometry)
    case geometryCollection([GeoJSONGeometry])
    
    public var features: [GeoJSONFeature]? {
        return switch self {
        case .featureCollection(let array):
            array
        case .feature(let feature):
            [feature]
        default:
            nil
        }
    }
    
    public var geometries: [GeoJSONGeometry]? {
        return switch self {
        case .geometryCollection(let array):
            array
        case .geometry(let geometry):
            [geometry]
        default:
            nil
        }
    }
}

extension GeoJSONObject: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case features
        case geometries
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "FeatureCollection":
            self = .featureCollection(try container.decode([GeoJSONFeature].self, forKey: .features))
        case "Feature":
            self = .feature(try GeoJSONFeature(from: decoder))
        case "GeometryCollection":
            self = .geometryCollection(try container.decode([GeoJSONGeometry].self, forKey: .geometries))
        case "Point", "LineString", "Polygon", "MultiLineString", "MultiPolygon", "MultiPoint":
            self = .geometry(try GeoJSONGeometry(from: decoder))
        default:
            throw GeoJSONDecodingError.unexpectedType(type)
        }
    }
}
