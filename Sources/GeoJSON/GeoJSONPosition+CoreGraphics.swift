//
//  GeoJSONPosition+CoreGraphics.swift
//  swift-geojson
//
//  Created by Greg Whatley on 9/21/25.
//

#if canImport(CoreGraphics)
import CoreGraphics

public extension GeoJSONPosition {
    var cgPoint: CGPoint {
        .init(x: latitude, y: longitude)
    }
}
#endif
