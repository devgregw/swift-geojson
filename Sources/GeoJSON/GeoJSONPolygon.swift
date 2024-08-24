//
//  GeoJSONPolygon.swift
//
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation

public struct GeoJSONPolygon: Hashable, Sendable {
    public let exterior: GeoJSONLinearRing
    public let holes: [GeoJSONLinearRing]
    
    public init(exterior: GeoJSONLinearRing, holes: [GeoJSONLinearRing]) {
        self.exterior = exterior
        self.holes = holes
    }
    
    public init(_ exterior: GeoJSONLinearRing) {
        self.init(exterior: exterior, holes: [])
    }
}

extension GeoJSONPolygon: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rings: [GeoJSONLinearRing] = try container.decode([GeoJSONLinearRing].self)
        guard !rings.isEmpty,
              let exterior = rings.first else {
            throw GeoJSONDecodingError.notEnoughMembers(rings, got: 0, expected: 1)
        }
        try rings.forEach {
            guard $0.count >= 4 else {
                throw GeoJSONDecodingError.notEnoughMembers($0, got: $0.count, expected: 4)
            }
        }
        self.init(exterior: exterior, holes: Array(rings[1...]))
    }
}
