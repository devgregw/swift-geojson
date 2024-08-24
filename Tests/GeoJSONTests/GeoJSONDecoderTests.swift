import XCTest
@testable import GeoJSON

final class GeoJSONTests: XCTestCase {
    private var decoder: GeoJSONDecoder!
    
    override func setUp() {
        decoder = .init()
    }
    
    private func object(forJSON json: String) throws -> GeoJSONObject {
        let data = json.data(using: .utf8) ?? Data()
        return try decoder.decode(from: data)
    }
    
    func testDecodePoint() throws {
        let decoded = try object(forJSON: """
        {
            "type": "Point",
            "coordinates": [100.0, 0.0]
        }
        """)
        let expected = GeoJSONObject.geometry(.point(.init(latitude: 100.0, longitude: 0.0)))
        XCTAssertEqual(decoded, expected)
        
        let invalid = """
        {
            "type": "Point",
            "coordinates": [100.0]
        }
        """
        XCTAssertThrowsError(try object(forJSON: invalid))
    }
    
    func testDecodeLineString() throws {
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
        XCTAssertEqual(decoded, expected)
        
        let invalid = """
        {
            "type": "LineString",
            "coordinates": []
        }
        """
        XCTAssertThrowsError(try object(forJSON: invalid))
    }
    
    func testDecodePolygonNoHoles() throws {
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
        XCTAssertEqual(decoded, expected)
    }
    
    func testDecodePolygonWithHoles() throws {
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
        XCTAssertEqual(decoded, expected)
    }
    
    func testMultiPoint() throws {
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
        XCTAssertEqual(decoded, expected)
    }
    
    func testMultiLineString() throws {
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
        XCTAssertEqual(decoded, expected)
    }
    
    func testMultiPolygon() throws {
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
            .init([
                .init(latitude: 102.0, longitude: 2.0),
                .init(latitude: 103.0, longitude: 2.0),
                .init(latitude: 103.0, longitude: 3.0),
                .init(latitude: 102.0, longitude: 3.0),
                .init(latitude: 102.0, longitude: 2.0)
            ]),
            .init(exterior: [
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
        XCTAssertEqual(decoded, expected)
    }
    
    func testDecodeFeature() throws {
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
        XCTAssertEqual(decoded, expected)
    }
    
    func testDecodeGeometryCollection() throws {
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
        XCTAssertEqual(decoded, expected)
    }
    
    func testDecodeFeatureCollection() throws {
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
        XCTAssertEqual(decoded, expected)
    }
}
