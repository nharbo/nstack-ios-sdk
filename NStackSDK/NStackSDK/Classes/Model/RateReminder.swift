//
//  RateReminder.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

struct RateReminder: Codable {
    var id = 0
    var title = ""
    var body = ""
    var yesButtonTitle = ""     // <-yesBtn
    var laterButtonTitle = ""   // <-laterBtn
    var noButtonTitle = ""      // <-noBtn
    var link: URL?
    
    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try map.decode(Int.self, forKey: .id)
        self.title = try map.decode(String.self, forKey: .title)
        self.body = try map.decode(String.self, forKey: .body)
        self.yesButtonTitle = try map.decode(String.self, forKey: .yesButtonTitle)
        self.laterButtonTitle = try map.decode(String.self, forKey: .laterButtonTitle)
        self.noButtonTitle = try map.decode(String.self, forKey: .noButtonTitle)
        self.link = try map.decode(URL.self, forKey: .id)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case yesButtonTitle = "yesBtn"
        case laterButtonTitle = "laterBtn"
        case noButtonTitle = "noBtn"
        case link
    }
    
}

