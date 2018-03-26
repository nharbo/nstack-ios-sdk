//
//  AppOpenResponse.swift
//  NStack
//
//  Created by Andrew Lloyd on 04/02/2016.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation

// TODO: Fix update struct in app open and adjust fetchUpdates response model

struct AppOpenResponse: Codable {
    var data: AppOpenData?
    var languageData: LanguageData? // <-meta

    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try map.decode(String.self, forKey: .data)
        self.languageData = try map.decode(String.self, forKey: .languageData)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case languageData = "meta"
    }
}


