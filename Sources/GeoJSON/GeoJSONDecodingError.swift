//
//  GeoJSONDecodingError.swift
//  
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation

public enum GeoJSONDecodingError: Error, CustomStringConvertible {
    case userInfoInvalid
    case unexpectedType(String)
    case notEnoughMembers([Any], got: Int, expected: Int)
    
    public var description: String {
        switch self {
        case .userInfoInvalid:
            "User info invalid - use GeoJSONDecoder."
        case .unexpectedType(let type):
            "Unexpected object type: \(type)."
        case .notEnoughMembers(_, let got, let expected):
            "Not enough members of array (got \(got), expected \(expected))."
        }
    }
}
