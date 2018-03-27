//
//  Timezone.swift
//  NStack
//
//  Created by Chris on 27/10/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

public struct Timezone : Codable {
	public var id = 0
	public var name = ""
	public var abbreviation = "" //<-abbr
	public var offsetSec = 0
	public var label = ""
    
    public init() {}
    
    public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try map.decode(Int.self, forKey: .id)
        self.name = try map.decode(String.self, forKey: .name)
        self.abbreviation = try map.decode(String.self, forKey: .abbreviation)
        self.offsetSec = try map.decode(Int.self, forKey: .offsetSec)
        self.label = try map.decode(String.self, forKey: .label)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case abbreviation = "abbr"
        case offsetSec = "offset_sec"
        case label
    }
}

