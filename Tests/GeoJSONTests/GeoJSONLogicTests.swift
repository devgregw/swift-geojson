//
//  GeoJSONLogicTests.swift
//  swift-geojson
//
//  Created by Greg Whatley on 9/21/25.
//

import Foundation
@testable import GeoJSON
import Testing

@Suite("Logic") struct GeoJSONLogicTests {
    @Test("Polygon w/o holes contains points") func polygonWithoutHolesContainsPoints() {
        let polygon = GeoJSONPolygon([
            .init(latitude: 100.0, longitude: 0.0),
            .init(latitude: 101.0, longitude: 0.0),
            .init(latitude: 101.0, longitude: 1.0),
            .init(latitude: 100.0, longitude: 1.0),
            .init(latitude: 100.0, longitude: 0.0)
        ])

        #expect(polygon.contains(.init(latitude: 100.5, longitude: 0.5)))
        #expect(!polygon.contains(.init(latitude: 0.0, longitude: 0.0)))
        #expect(polygon.boundingBox == GeoJSONBoundingBox(origin: .init(latitude: 100.0, longitude: 0.0), size: .init(width: 1.0, height: 1.0)))
    }

    @Test("Polygon w/ holes contains points") func polygonWithHolesContainsPoints() {
        let polygon = GeoJSONPolygon(exterior: [
            .init(latitude: 100.0, longitude: 0.0),
            .init(latitude: 101.0, longitude: 0.0),
            .init(latitude: 101.0, longitude: 1.0),
            .init(latitude: 100.0, longitude: 1.0),
            .init(latitude: 100.0, longitude: 0.0)
        ], holes: [
            [
                .init(latitude: 100.8, longitude: 0.8),
                .init(latitude: 100.8, longitude: 0.2),
                .init(latitude: 100.2, longitude: 0.2),
                .init(latitude: 100.2, longitude: 0.8),
                .init(latitude: 100.8, longitude: 0.8)
            ]
        ])

        #expect(polygon.contains(.init(latitude: 100.1, longitude: 0.1)))
        #expect(!polygon.contains(.init(latitude: 100.5, longitude: 0.5)))
        #expect(polygon.contains(.init(latitude: 100.5, longitude: 0.5), ignoreHoles: true))
        #expect(!polygon.contains(.init(latitude: 0, longitude: 0)))
        #expect(polygon.boundingBox == GeoJSONBoundingBox(origin: .init(latitude: 100.0, longitude: 0.0), size: .init(width: 1.0, height: 1.0)))
    }

    @Test("Multi polygon contains points") func multiPolygonContainsPoints() {
        let multiPolygon = [
            GeoJSONPolygon([
                .init(latitude: 102.0, longitude: 2.0),
                .init(latitude: 103.0, longitude: 2.0),
                .init(latitude: 103.0, longitude: 3.0),
                .init(latitude: 102.0, longitude: 3.0),
                .init(latitude: 102.0, longitude: 2.0)
            ]),
            GeoJSONPolygon(exterior: [
                .init(latitude: 100.0, longitude: 0.0),
                .init(latitude: 101.0, longitude: 0.0),
                .init(latitude: 101.0, longitude: 1.0),
                .init(latitude: 100.0, longitude: 1.0),
                .init(latitude: 100.0, longitude: 0.0)
            ], holes: [
                [
                    .init(latitude: 100.2, longitude: 0.2),
                    .init(latitude: 100.2, longitude: 0.8),
                    .init(latitude: 100.8, longitude: 0.8),
                    .init(latitude: 100.8, longitude: 0.2),
                    .init(latitude: 100.2, longitude: 0.2)
                ]
            ])
        ]

        #expect(multiPolygon.contains(.init(latitude: 100.1, longitude: 0.1)))
        #expect(multiPolygon.contains(.init(latitude: 102.5, longitude: 2.5)))
        #expect(!multiPolygon.contains(.init(latitude: 100.5, longitude: 0.5)))
        #expect(multiPolygon.contains(.init(latitude: 100.5, longitude: 0.5), ignoreHoles: true))
        #expect(!multiPolygon.contains(.init(latitude: 0, longitude: 0)))
    }
}
