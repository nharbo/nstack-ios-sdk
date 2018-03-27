//
//  Update.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

enum UpdateState: String, Codable {
    case Disabled    = "no"
    case Remind      = "yes"
    case Force       = "force"
}

struct Update: Codable {
    var newInThisVersion:Changelog?
    var newerVersion:Version?
    
    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.newInThisVersion = try? map.decode(Changelog.self, forKey: .newInThisVersion)
        self.newerVersion = try? map.decode(Version.self, forKey: .newerVersion)
    }
    
    private enum CodingKeys: String, CodingKey {
        case newInThisVersion = "new_in_version"
        case newerVersion = "newer_version"
    }
    
    struct UpdateTranslations: Codable {
        var title       = ""
        var message     = ""
        var positiveBtn = ""
        var negativeBtn = ""
        
        init() {}
        
        init(from decoder: Decoder) throws {
            let map = try decoder.container(keyedBy: UpdateTranslationsCodingKeys.self)
            self.title = try map.decode(String.self, forKey: .title)
            self.message = try map.decode(String.self, forKey: .message)
            self.positiveBtn = try map.decode(String.self, forKey: .positiveBtn)
            self.negativeBtn = try map.decode(String.self, forKey: .negativeBtn)
        }
        
        private enum UpdateTranslationsCodingKeys: String, CodingKey {
            case title
            case message
            case positiveBtn
            case negativeBtn
        }
    }
    
    struct Update: Codable {
        var newInThisVersion:Changelog? //<-new_in_version
        var newerVersion:Version?
        
        init(from decoder: Decoder) throws {
            let map = try decoder.container(keyedBy: UpdateCodingKeys.self)
            self.newInThisVersion = try? map.decode(Changelog.self, forKey: .newInThisVersion)
            self.newerVersion = try? map.decode(Version.self, forKey: .newerVersion)
        }
        
        private enum UpdateCodingKeys: String, CodingKey {
            case newInThisVersion = "new_in_version"
            case newerVersion = "newer_version"
        }
    }
    
    struct Changelog: Codable {
        var state = false
        var lastId = 0
        var version = ""
        var translate:UpdateTranslations?
        
        init(from decoder: Decoder) throws {
            let map = try decoder.container(keyedBy: ChangelogCodingKeys.self)
            self.state = try map.decode(Bool.self, forKey: .state)
            self.lastId = try map.decode(Int.self, forKey: .lastId)
            self.version = try map.decode(String.self, forKey: .version)
            self.translate = try? map.decode(UpdateTranslations.self, forKey: .translate)
        }
        
        private enum ChangelogCodingKeys: String, CodingKey {
            case state
            case lastId = "last_id"
            case version
            case translate
        }
    }
    
    struct Version: Codable {
        var state = UpdateState.Disabled
        var lastId = 0
        var version = ""
        var translations = UpdateTranslations() //<-translate
        var link: URL?
        
        init(from decoder: Decoder) throws {
            let map = try decoder.container(keyedBy: VersionCodingKeys.self)
            self.state = try map.decode(UpdateState.self, forKey: .state)
            self.lastId = try map.decode(Int.self, forKey: .lastId)
            self.version = try map.decode(String.self, forKey: .version)
            self.translations = try map.decode(UpdateTranslations.self, forKey: .translations)
            self.link = try? map.decode(URL.self, forKey: .link)
        }
        
        private enum VersionCodingKeys: String, CodingKey {
            case state
            case lastId = "last_id"
            case version
            case translations = "translate"
            case link
        }
    }
}
