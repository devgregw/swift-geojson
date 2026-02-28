//
//  GeoJSONDecoder.swift
//
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation

final public class GeoJSONDecoder: JSONDecoder, @unchecked Sendable {
    enum UserInfoKeys {
        static let options = CodingUserInfoKey(rawValue: "GeoJSONDecoderOptions")!
    }
    
    private func setUserInfo(options: GeoJSONDecoderOptions) throws {
        userInfo[UserInfoKeys.options] = options
    }
    
    public func decode(_ data: Data, options: GeoJSONDecoderOptions = .none) throws -> GeoJSONObject {
        try setUserInfo(options: options)
        return try super.decode(GeoJSONObject.self, from: data)
    }
}
