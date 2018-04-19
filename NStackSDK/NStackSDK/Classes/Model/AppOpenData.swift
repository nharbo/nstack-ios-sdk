//
//  AppOpenData.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation

struct AppOpenData: Decodable {
    var count = 0

    var message: Message?
    var update: Update?
    var rateReminder: RateReminder?

    var translate: [String: AnyJSONType]?
    var deviceMapping: [String: String] = [:] // <-ios_devices

    var createdAt = Date()
    var lastUpdated = Date()
    
    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.count = try map.decode(Int.self, forKey: .count)
        self.message = try? map.decode(Message.self, forKey: .message)
        self.update = try? map.decode(Update.self, forKey: .update)
        self.rateReminder = try? map.decode(RateReminder.self, forKey: .rateReminder)
        self.translate = try? map.decode([String: AnyJSONType].self, forKey: .translate)
        self.deviceMapping = try map.decode([String: String].self, forKey: .deviceMapping)
        self.createdAt = try map.decode(Date.self, forKey: .createdAt)
        self.lastUpdated = try map.decode(Date.self, forKey: .lastUpdated)
    }
    
//    func encode(to encoder: Encoder) throws {
//        var map = encoder.container(keyedBy: CodingKeys.self)
//        try map.encode(count, forKey: .count)
//        try? map.encode(message, forKey: .message)
//        try? map.encode(update, forKey: .update)
//        try? map.encode(rateReminder, forKey: .rateReminder)
//        try? map.encode(translate, forKey: .translate)
//        try map.encode(deviceMapping, forKey: .deviceMapping)
//        try map.encode(createdAt, forKey: .createdAt)
//        try map.encode(lastUpdated, forKey: .lastUpdated)
//    }
    
    private enum CodingKeys: String, CodingKey {
        case count
        case message
        case update
        case rateReminder = "rate_reminder"
        case translate
        case deviceMapping = "ios_devices"
        case createdAt = "created_at"
        case lastUpdated = "last_updated"
    }
}

