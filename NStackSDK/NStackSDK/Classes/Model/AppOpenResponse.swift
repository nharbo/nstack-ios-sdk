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
    
    init(dictionary: [String: Any]) {
        data = dictionary["data"] as? AppOpenData
        languageData = dictionary["meta"] as? LanguageData
    }

    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try? map.decode(AppOpenData.self, forKey: .data)
        self.languageData = try? map.decode(LanguageData.self, forKey: .languageData)
    }
    
    private enum CodingKeys: String, CodingKey {
        case data
        case languageData = "meta"
    }
}


