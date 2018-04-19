//
//  TranslationsResponse.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 15/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

struct TranslationsResponse: Codable {
    var translations: [String: AnyJSONType]? // <-data
    var languageData: LanguageData? // <-meta
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.translations = try? map.decode([String: AnyJSONType].self, forKey: .translations)
        self.languageData = try? map.decode(LanguageData.self, forKey: .languageData)
    }
    
    //TODO: Find a model for translations
     func encode(to encoder: Encoder) throws {
        var map = encoder.container(keyedBy: CodingKeys.self)
//        try? map.encode(translations, forKey: .translations)
        try? map.encode(languageData, forKey: .languageData)
      //  try? map.encode(translations, forKey: .translations)
    }
    
    private enum CodingKeys: String, CodingKey {
        case translations = "data"
        case languageData = "meta"
    }
}

