//
//  GeoJSONBoundingBox.swift
//  swift-geojson
//
//  Created by Greg Whatley on 9/21/25.
//

#if canImport(CoreGraphics)
import CoreGraphics
#endif
import Foundation

public struct GeoJSONBoundingBox: Hashable, Sendable {
    public struct Origin: Hashable, Sendable {
        public let latitude: Double
        public let longitude: Double

        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }

#if canImport(CoreGraphics)
        public var cgPoint: CGPoint {
            .init(x: latitude, y: longitude)
        }
#endif
    }

    public struct Size: Hashable, Sendable {
        public let width: Double
        public let height: Double

        public init(width: Double, height: Double) {
            self.width = width
            self.height = height
        }

#if canImport(CoreGraphics)
        public var cgSize: CGSize {
            .init(width: width, height: height)
        }
#endif
    }

    public let origin: Origin
    public let size: Size

    public init(origin: Origin, size: Size) {
        self.origin = origin
        self.size = size
    }

    public init?(bounding positions: [GeoJSONPosition]) {
        guard !positions.isEmpty else { return nil }
        var minX = positions[0].latitude
        var maxX = positions[0].latitude
        var minY = positions[0].longitude
        var maxY = positions[0].longitude

        for point in positions {
            if point.latitude < minX { minX = point.latitude }
            if point.latitude > maxX { maxX = point.latitude }
            if point.longitude < minY { minY = point.longitude }
            if point.longitude > maxY { maxY = point.longitude }
        }
        self.init(origin: .init(latitude: minX, longitude: minY), size: .init(width: maxX - minX, height: maxY - minY))
    }

    public func contains(_ position: GeoJSONPosition) -> Bool {
#if canImport(CoreGraphics)
        cgRect.contains(position.cgPoint)
#else
        let x = position.latitude
        let y = position.longitude
        return x >= origin.latitude &&
               x <= origin.latitude + size.width &&
               y >= origin.longitude &&
               y <= origin.longitude + size.height
#endif
    }

#if canImport(CoreGraphics)
    public var cgRect: CGRect {
        .init(origin: origin.cgPoint, size: size.cgSize)
    }
#endif
}
