//
//  TranslationsResponse.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 15/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

struct TranslationsResponse {
    var translations: NSDictionary? // <-data
    var languageData: LanguageData? // <-meta
    
    
    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.translations = try map.decode(String.self, forKey: .translations)
        self.languageData = try map.decode(String.self, forKey: .languageData)
    }
    
    private enum CodingKeys: String, CodingKey {
        case translations = "data"
        case languageData = "meta"
    }
}

