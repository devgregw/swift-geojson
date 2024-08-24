//
//  GeoJSONFeature.swift
//
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation

public struct GeoJSONFeature: Hashable, Sendable {
    public typealias Properties = [String: String]
    
    public let geometry: GeoJSONGeometry
    public let properties: Properties
    
    public init(geometry: GeoJSONGeometry, properties: Properties) {
        self.geometry = geometry
        self.properties = properties
    }
}

extension GeoJSONFeature: Decodable {
    private enum CodingKeys: CodingKey {
        case geometry
        case properties
    }
    
    private static func decodeProperties(from decoder: any Decoder) throws -> [String: Any] {
        guard let key = CodingUserInfoKey(rawValue: "jsonData"),
              let jsonData = decoder.userInfo[key] as? [String: Any],
              let type = jsonData["type"] as? String else {
            throw GeoJSONDecodingError.userInfoInvalid
        }
        if type == "Feature",
           let properties = jsonData["properties"] as? [String: Any] {
            return properties
        } else if type == "FeatureCollection",
                  let idx = decoder.codingPath.last?.intValue,
                  let features = jsonData["features"] as? [[String: Any]],
                  features.indices ~= idx,
                  let properties = features[idx]["properties"] as? [String: Any] {
            return properties
        } else {
            throw GeoJSONDecodingError.userInfoInvalid
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.geometry = try container.decode(GeoJSONGeometry.self, forKey: .geometry)
        self.properties = try Self.decodeProperties(from: decoder).mapValues { String(describing: $0).trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}
