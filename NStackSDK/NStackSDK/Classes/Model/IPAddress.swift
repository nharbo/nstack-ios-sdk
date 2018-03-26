//
//  IPAddress.swift
//  NStackSDK
//
//  Created by Christian Graver on 01/11/2017.
//  Copyright © 2017 Nodes ApS. All rights reserved.
//

import Foundation

public struct IPAddress: Codable {
    public var ipStart = ""
    public var ipEnd = ""
    public var country = ""
    public var stateProv = ""
    public var city = ""
    public var lat = ""
    public var lng = ""
    public var timeZoneOffset = ""
    public var timeZoneName = ""
    public var ispName = ""
    public var connectionType = ""
    public var type = ""
    public var requestedIp = ""
    
    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.ipStart = try map.decode(String.self, forKey: .ipStart)
        self.ipEnd = try map.decode(String.self, forKey: .ipEnd)
        self.country = try map.decode(String.self, forKey: .country)
        self.stateProv = try map.decode(String.self, forKey: .stateProv)
        self.city = try map.decode(String.self, forKey: .city)
        self.lat = try map.decode(String.self, forKey: .lat)
        self.lng = try map.decode(String.self, forKey: .lng)
        self.timeZoneOffset = try map.decode(String.self, forKey: .timeZoneOffset)
        self.timeZoneName = try map.decode(String.self, forKey: .timeZoneName)
        self.ispName = try map.decode(String.self, forKey: .ispName)
        self.connectionType = try map.decode(String.self, forKey: .connectionType)
        self.type = try map.decode(String.self, forKey: .type)
        self.requestedIp = try map.decode(String.self, forKey: .requestedIp)
    }
    
    private enum CodingKeys: String, CodingKey {
        case ipStart = "ip_start"
        case ipEnd = "ip_end"
        case country = "country"
        case stateProv = "state_prov"
        case city = "city"
        case lat = "lat"
        case lng = "lng"
        case timeZoneOffset = "time_zone_offset"
        case timeZoneName = "time_zone_name"
        case connectionType = "connection_type"
        case type = "type"
        case requestedIp = "requested_ip"
    }
}

