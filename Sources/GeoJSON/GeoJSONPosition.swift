//
//  GeoJSONPosition.swift
//  
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation

public struct GeoJSONPosition: Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension GeoJSONPosition: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode([Double].self)
        guard values.count >= 2 else {
            throw GeoJSONDecodingError.notEnoughMembers(values, got: values.count, expected: 2)
        }
        latitude = values[0]
        longitude = values[1]
    }
}

public typealias GeoJSONLineString = [GeoJSONPosition]
public typealias GeoJSONLinearRing = [GeoJSONPosition]
