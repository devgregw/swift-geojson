//
//  GeoJSONDecoderOptions.swift
//
//
//  Created by Greg Whatley on 8/25/24.
//

import Foundation

public struct GeoJSONDecoderOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none: GeoJSONDecoderOptions = []
    public static let swapLatitudeLongitude = GeoJSONDecoderOptions(rawValue: 1 << 0)
}
