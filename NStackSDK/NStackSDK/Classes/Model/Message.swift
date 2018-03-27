//
//  Message.swift
//  NStack
//
//  Created by Kasper Welner on 21/10/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

internal struct Message: Codable {
    var id = ""
    var message = ""
    var showSetting = ""
    
    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try map.decode(String.self, forKey: .id)
        self.message = try map.decode(String.self, forKey: .message)
        self.showSetting = try map.decode(String.self, forKey: .showSetting)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case message
        case showSetting = "show_setting"
    }
}
