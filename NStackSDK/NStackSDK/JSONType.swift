//
//  JSONType.swift
//  NStackSDK
//
//  Created by Andrei Hogea on 12/04/2018.
//  Copyright © 2018 Nodes ApS. All rights reserved.
//

import Foundation

public protocol JSONType: Codable {
    var jsonValue: Codable { get }
}

extension Int: JSONType {
    public var jsonValue: Codable { return self }
}
extension String: JSONType {
    public var jsonValue: Codable { return self }
}
extension Double: JSONType {
    public var jsonValue: Codable { return self }
}
extension Bool: JSONType {
    public var jsonValue: Codable { return self }
}

public struct AnyJSONType: JSONType {
    public let jsonValue: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            jsonValue = intValue
        } else if let stringValue = try? container.decode(String.self) {
            jsonValue = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            jsonValue = boolValue
        } else if let doubleValue = try? container.decode(Double.self) {
            jsonValue = doubleValue
        } else if let doubleValue = try? container.decode(Array<AnyJSONType>.self) {
            jsonValue = doubleValue
        } else if let doubleValue = try? container.decode(Dictionary<String, AnyJSONType>.self) {
            jsonValue = doubleValue
        } else {
            throw DecodingError.typeMismatch(JSONType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON tyep"))
        }
    }
 
    public func encode(to encoder: Encoder) throws {
        var container = try encoder.singleValueContainer()
        let encodableValue = jsonValue as Encodable
        try? container.encode(encodableValue)

    }
}

