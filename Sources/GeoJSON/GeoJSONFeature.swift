//
//  GeoJSONFeature.swift
//
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation

public struct GeoJSONFeature: Hashable, Sendable {
    public let geometry: GeoJSONGeometry
    public let properties: Properties
    
    public init(geometry: GeoJSONGeometry, properties: Properties) {
        self.geometry = geometry
        self.properties = properties
    }

    public var isEmpty: Bool {
        geometry.isEmpty
    }
}

extension GeoJSONFeature: Decodable {
    private enum CodingKeys: CodingKey {
        case geometry
        case properties
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.geometry = try container.decode(GeoJSONGeometry.self, forKey: .geometry)
        self.properties = try container.decodeIfPresent(Properties.self, forKey: .properties) ?? [:]
    }
}
