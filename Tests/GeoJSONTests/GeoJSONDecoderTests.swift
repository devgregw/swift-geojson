//
//  GeoJSONDecoderTests.swift
//  swift-geojson
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation
@testable import GeoJSON
import Testing

@Suite("GeoJSONDecoder") struct GeoJSONDecoderTests {
    private func object(forJSON json: String, options: GeoJSONDecoderOptions = .none) throws -> GeoJSONObject {
        let data = json.data(using: .utf8) ?? Data()
        return try GeoJSONDecoder().decode(data, options: options)
    }

    @Test("Decode a point") func decodePoint() throws {
        let decoded = try object(forJSON: """
        {
            "type": "Point",
            "coordinates": [100.0, 0.0]
        }
        """)

        let expected = GeoJSONObject.geometry(.point(.init(latitude: 100.0, longitude: 0.0)))

        #expect(decoded == expected)

        let invalid = """
        {
            "type": "Point",
            "coordinates": [100.0]
        }
        """

        #expect(throws: GeoJSONDecodingError.self) {
            try object(forJSON: invalid)
        }
    }

    @Test("Decode a point with coordinates swapped") func decodePointSwapped() throws {
        let decoded = try object(forJSON: """
        {
            "type": "Point",
            "coordinates": [100.0, 0.0]
        }
        """, options: .swapLatitudeLongitude)

        let expected = GeoJSONObject.geometry(.point(.init(latitude: 0.0, longitude: 100.0)))

        #expect(decoded == expected)
    }

    @Test("Decode a line string") func decodeLineString() throws {
        let decoded = try object(forJSON: """
        {
            "type": "LineString",
            "coordinates": [
                [100.0, 0.0],
                [101.0, 1.0]
            ]
        }
        """)

        let expected = GeoJSONObject.geometry(.lineString([
            .init(latitude: 100.0, longitude: 0), .init(latitude: 101.0, longitude: 1.0)
        ]))

        #expect(decoded == expected)

        let invalid = """
        {
            "type": "LineString",
            "coordinates": []
        }
        """

        #expect(throws: GeoJSONDecodingError.self) {
            try object(forJSON: invalid)
        }
    }

    @Test("Decode a polygon w/o holes") func decodePolygonNoHoles() throws {
        let decoded = try object(forJSON: """
        {
            "type": "Polygon",
            "coordinates": [
                [
                    [100.0, 0.0],
                    [101.0, 0.0],
                    [101.0, 1.0],
                    [100.0, 1.0],
                    [100.0, 0.0]
                ]
            ]
        }
        """)

        let expected = GeoJSONObject.geometry(.polygon(.init([
            .init(latitude: 100.0, longitude: 0.0),
            .init(latitude: 101.0, longitude: 0.0),
            .init(latitude: 101.0, longitude: 1.0),
            .init(latitude: 100.0, longitude: 1.0),
            .init(latitude: 100.0, longitude: 0.0)
        ])))

        #expect(decoded == expected)

    }

    @Test("Decode a polygon w/ holes") func decodePolygonWithHoles() throws {
        let decoded = try object(forJSON: """
        {
            "type": "Polygon",
            "coordinates": [
                [
                    [100.0, 0.0],
                    [101.0, 0.0],
                    [101.0, 1.0],
                    [100.0, 1.0],
                    [100.0, 0.0]
                ],
                [
                    [100.8, 0.8],
                    [100.8, 0.2],
                    [100.2, 0.2],
                    [100.2, 0.8],
                    [100.8, 0.8]
                ]
            ]
        }
        """)

        let expected = GeoJSONObject.geometry(.polygon(.init(exterior: [
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
        ])))

        #expect(decoded == expected)
    }

    @Test("Decode a multi point") func decodeMultiPoint() throws {
        let decoded = try object(forJSON: """
        {
            "type": "MultiPoint",
            "coordinates": [
                [100.0, 0.0],
                [101.0, 1.0]
            ]
        }
        """)

        let expected = GeoJSONObject.geometry(.multiPoint([
            .init(latitude: 100.0, longitude: 0.0),
            .init(latitude: 101.0, longitude: 1.0)
        ]))

        #expect(decoded == expected)
    }

    @Test("Decode a multi line string") func decodeMultiLineString() throws {
        let decoded = try object(forJSON: """
        {
            "type": "MultiLineString",
            "coordinates": [
                [
                    [100.0, 0.0],
                    [101.0, 1.0]
                ],
                [
                    [102.0, 2.0],
                    [103.0, 3.0]
                ]
            ]
        }
        """)

        let expected = GeoJSONObject.geometry(.multiLineString([
            [
                .init(latitude: 100.0, longitude: 0.0),
                .init(latitude: 101.0, longitude: 1.0)
            ],
            [
                .init(latitude: 102.0, longitude: 2.0),
                .init(latitude: 103.0, longitude: 3.0)
            ]
        ]))

        #expect(decoded == expected)
    }

    @Test("Decode a multi polygon") func decodeMultiPolygon() throws {
        let decoded = try object(forJSON: """
        {
            "type": "MultiPolygon",
            "coordinates": [
                [
                    [
                        [102.0, 2.0],
                        [103.0, 2.0],
                        [103.0, 3.0],
                        [102.0, 3.0],
                        [102.0, 2.0]
                    ]
                ],
                [
                    [
                        [100.0, 0.0],
                        [101.0, 0.0],
                        [101.0, 1.0],
                        [100.0, 1.0],
                        [100.0, 0.0]
                    ],
                    [
                        [100.2, 0.2],
                        [100.2, 0.8],
                        [100.8, 0.8],
                        [100.8, 0.2],
                        [100.2, 0.2]
                    ]
                ]
            ]
        }
        """)

        let expected = GeoJSONObject.geometry(.multiPolygon([
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
        ]))

        #expect(decoded == expected)
    }

    @Test("Decode a feature") func decodeFeature() throws {
        let decoded = try object(forJSON: """
        {
            "type": "Feature",
            "geometry": {
                "type": "LineString",
                "coordinates": [
                    [102.0, 0.0],
                    [103.0, 1.0],
                    [104.0, 0.0],
                    [105.0, 1.0]
                ]
            },
            "properties": {
                "prop0": "value0",
                "prop1": 0.0
            }
        }
        """)

        let expected = GeoJSONObject.feature(.init(geometry: .lineString([
            .init(latitude: 102.0, longitude: 0.0),
            .init(latitude: 103.0, longitude: 1.0),
            .init(latitude: 104.0, longitude: 0.0),
            .init(latitude: 105.0, longitude: 1.0)
        ]), properties: [
            "prop0": "value0",
            "prop1": "0"
        ]))

        #expect(decoded == expected)
    }

    @Test("Decode a geometry collection") func decodeGeometryCollection() throws {
        let decoded = try object(forJSON: """
        {
            "type": "GeometryCollection",
            "geometries": [{
                "type": "Point",
                "coordinates": [100.0, 0.0]
            }, {
                "type": "LineString",
                "coordinates": [
                    [101.0, 0.0],
                    [102.0, 1.0]
                ]
            }]
        }
        """)

        let expected = GeoJSONObject.geometryCollection([
            .point(.init(latitude: 100.0, longitude: 0.0)),
            .lineString([
                .init(latitude: 101.0, longitude: 0.0),
                .init(latitude: 102.0, longitude: 1.0)
            ])
        ])

        #expect(decoded == expected)
    }

    @Test("Decode a feature collection") func decodeFeatureCollection() throws {
        let decoded = try object(forJSON: """
        {
           "type": "FeatureCollection",
           "features": [{
               "type": "Feature",
               "geometry": {
                   "type": "Point",
                   "coordinates": [102.0, 0.5]
               },
               "properties": {
                   "prop0": "value0"
               }
           }, {
               "type": "Feature",
               "geometry": {
                   "type": "LineString",
                   "coordinates": [
                       [102.0, 0.0],
                       [103.0, 1.0],
                       [104.0, 0.0],
                       [105.0, 1.0]
                   ]
               },
               "properties": {
                    "prop0": "value0",
                    "prop1": 0.0
                }
            }, {
                "type": "Feature",
                "geometry": {
                    "type": "Polygon",
                    "coordinates": [
                        [
                            [100.0, 0.0],
                            [101.0, 0.0],
                            [101.0, 1.0],
                            [100.0, 1.0],
                            [100.0, 0.0]
                        ]
                    ]
                },
                "properties": {
                    "prop0": "value0",
                    "prop1": {
                        "this": "that"
                    }
                }
            }]
        }
        """)

        let expected = GeoJSONObject.featureCollection([
            .init(geometry: .point(.init(latitude: 102.0, longitude: 0.5)), properties: ["prop0": "value0"]),
            .init(geometry: .lineString([
                .init(latitude: 102.0, longitude: 0.0),
                .init(latitude: 103.0, longitude: 1.0),
                .init(latitude: 104.0, longitude: 0.0),
                .init(latitude: 105.0, longitude: 1.0)
            ]), properties: [
                "prop0": "value0",
                "prop1": "0"
            ]),
            .init(geometry: .polygon(.init([
                .init(latitude: 100.0, longitude: 0.0),
                .init(latitude: 101.0, longitude: 0.0),
                .init(latitude: 101.0, longitude: 1.0),
                .init(latitude: 100.0, longitude: 1.0),
                .init(latitude: 100.0, longitude: 0.0)
            ])), properties: [
                "prop0": "value0",
                "prop1": "{\n    this = that;\n}"
            ])
        ])

        #expect(decoded == expected)
    }
}
