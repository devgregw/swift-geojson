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

    public var boundingBox: GeoJSONBoundingBox? {
        exterior.boundingBox
    }

    public func contains(_ position: GeoJSONPosition, ignoreHoles: Bool = false) -> Bool {
        guard exterior.boundingBox?.contains(position) == true,
              exterior.contains(position) else { return false }

        return ignoreHoles || !holes.contains { $0.contains(position) }
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
            guard $0.positions.count >= 4 else {
                throw GeoJSONDecodingError.notEnoughMembers($0.positions, got: $0.positions.count, expected: 4)
            }
        }
        self.init(exterior: exterior, holes: Array(rings[1...]))
    }
}

public extension Sequence where Element == GeoJSONPolygon {
    func contains(_ position: GeoJSONPosition, ignoreHoles: Bool = false) -> Bool {
        contains { $0.contains(position, ignoreHoles: ignoreHoles) }
    }
}
