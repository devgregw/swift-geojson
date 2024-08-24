//
//  GeoJSONDecoder.swift
//
//
//  Created by Greg Whatley on 8/24/24.
//

import Foundation

final public class GeoJSONDecoder: JSONDecoder {
    private func setUserInfo(data: Data) throws {
        guard let key = CodingUserInfoKey(rawValue: "jsonData") else { return }
        let object = try JSONSerialization.jsonObject(with: data)
        userInfo = [key: object]
    }
    
    public override func decode<T>(_ type: T.Type = GeoJSONObject.self, from data: Data) throws -> T where T : Decodable {
        try setUserInfo(data: data)
        return try super.decode(type, from: data)
    }
}
