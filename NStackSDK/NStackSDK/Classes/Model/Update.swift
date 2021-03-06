//
//  Update.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

enum UpdateState: String, Codable {
    case disabled    = "no"
    case remind      = "yes"
    case force       = "force"
}

struct Update: Codable {
    let newInThisVersion: Changelog?
    let newerVersion: Version?

    enum CodingKeys: String, CodingKey {
        case newInThisVersion = "new_in_version"
        case newerVersion = "newer_version"
    }

    struct UpdateTranslations: Codable {
        let title: String
        let message: String
        let positiveBtn: String?
        let negativeBtn: String?
    }

    struct Changelog: Codable {
        let state: Bool
        let lastId: Int
        let version: String
        let translate: UpdateTranslations?

        enum CodingKeys: String, CodingKey {
            case state, version, translate
            case lastId = "last_id"
        }
    }

    struct Version: Codable {
        let state: UpdateState
        let lastId: Int
        let version: String
        let translations: UpdateTranslations
        let link: URL?

        enum CodingKeys: String, CodingKey {
            case state, version, link
            case lastId = "last_id"
            case translations = "translate"
        }
    }
}
