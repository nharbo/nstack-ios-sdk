//
//  Language.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

public struct Language: Codable {
    public var id = 0
    public var name = ""
    public var locale = ""
    public var direction = ""
    public var acceptLanguage = "" // <-Accept-Language
    
    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try map.decode(Int.self, forKey: .id)
        self.name = try map.decode(String.self, forKey: .name)
        self.locale = try map.decode(String.self, forKey: .locale)
        self.direction = try map.decode(String.self, forKey: .direction)
        self.acceptLanguage = try map.decode(String.self, forKey: .acceptLanguage)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case locale
        case direction
        case acceptLanguage = "Accept-Language"
    }
    
}

extension Language: Serializable {
    public init(dictionary: NSDictionary?) {
        id             <== (self, dictionary, "id")
        name           <== (self, dictionary, "name")
        locale         <== (self, dictionary, "locale")
        direction      <== (self, dictionary, "direction")
        acceptLanguage <== (self, dictionary, "Accept-Language")
    }

    public func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "id")              <== id
        (dict, "name")            <== name
        (dict, "locale")          <== locale
        (dict, "direction")       <== direction
        (dict, "Accept-Language") <== acceptLanguage
        return dict
    }
}
