//
//  JSONSerialization+Sendable.swift
//  swift-geojson
//
//  Created by Greg Whatley on 7/5/25.
//

import Foundation

extension JSONSerialization {
    enum SerializationError: Error {
        case couldNotConvertToSendableStructures
    }
    
    static func sendableJSONObject(with data: Data, options: JSONSerialization.ReadingOptions = []) throws -> any Sendable {
        let object = try JSONSerialization.jsonObject(with: data, options: options)
        if let nsArray = object as? [any Sendable] {
            return nsArray
        } else if let nsDictionary = object as? [String: any Sendable] {
            return nsDictionary
        } else {
            throw SerializationError.couldNotConvertToSendableStructures
        }
    }
}
