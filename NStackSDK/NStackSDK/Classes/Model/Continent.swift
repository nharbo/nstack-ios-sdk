//
//  Continent.swift
//  NStackSDK
//
//  Created by Christian Graver on 01/11/2017.
//  Copyright © 2017 Nodes ApS. All rights reserved.
//

import Foundation

public struct Continent: Codable {
    public var id = 0
    public var name = ""
    public var code = ""
    public var imageURL: URL? //<- image
    
    public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try map.decode(Int.self, forKey: .id)
        self.name = try map.decode(String.self, forKey: .name)
        self.code = try map.decode(String.self, forKey: .code)
        self.imageURL = try map.decode(URL.self, forKey: .imageURL)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case code
        case imageURL = "image"
    }
}


