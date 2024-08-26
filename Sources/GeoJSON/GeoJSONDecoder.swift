//
//  GeoJSONDecoder.swift
//
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation

final public class GeoJSONDecoder: JSONDecoder {
    internal enum UserInfoKeys {
        static let jsonData = CodingUserInfoKey(rawValue: "jsonData")!
        static let options = CodingUserInfoKey(rawValue: "options")!
    }
    
    private func setUserInfo(data: Data, options: GeoJSONDecoderOptions) throws {
        let object = try JSONSerialization.jsonObject(with: data)
        userInfo = [
            UserInfoKeys.jsonData: object,
            UserInfoKeys.options: options
        ]
    }
    
    public func decode(_ data: Data, options: GeoJSONDecoderOptions = .none) throws -> GeoJSONObject {
        try setUserInfo(data: data, options: options)
        return try super.decode(GeoJSONObject.self, from: data)
    }
    
    @available(*, deprecated, renamed: "decode(_:options:)", message: "Migrate to decode(_:options:) to specify decoding options.")
    public override func decode<T>(_ type: T.Type = GeoJSONObject.self, from data: Data) throws -> T where T : Decodable {
        try setUserInfo(data: data, options: .none)
        return try super.decode(type, from: data)
    }
}
