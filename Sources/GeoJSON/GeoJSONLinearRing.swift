//
//  GeoJSONLinearRing.swift
//  swift-geojson
//
//  Created by Greg Whatley on 9/21/25.
//

import Foundation

public struct GeoJSONLinearRing: Hashable, Sendable {
    public let positions: [GeoJSONPosition]

    public init(_ positions: [GeoJSONPosition]) {
        self.positions = positions
    }

    public func contains(_ position: GeoJSONPosition) -> Bool {
        guard boundingBox?.contains(position) == true else { return false }
        return positions.dropLast().enumerated().reduce(into: false) { isInside, item in
            let nextVertex = positions[item.offset + 1]
            let x1 = item.element.latitude
            let y1 = item.element.longitude
            let x2 = nextVertex.latitude
            let y2 = nextVertex.longitude

            if ((y1 > position.longitude) != (y2 > position.longitude)),
               (position.latitude < (x2 - x1) * (position.longitude - y1) / (y2 - y1) + x1) {
                isInside.toggle()
            }
        }
    }

    public var boundingBox: GeoJSONBoundingBox? {
        .init(bounding: positions)
    }
}

extension GeoJSONLinearRing: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: GeoJSONPosition...) {
        self.positions = elements
    }
}

extension GeoJSONLinearRing: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.positions = try container.decode([GeoJSONPosition].self)
    }
}
