//
//  Country.swift
//  NStack
//
//  Created by Chris on 27/10/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

public struct Country: Codable {
	public var id = 0
	public var name = ""
	public var code = ""
	public var codeIso = ""
	public var native = ""
	public var phone = 0
	public var continent = ""
	public var capital = ""
	public var capitalLat = 0.0
	public var capitalLng = 0.0
	public var currency = ""
	public var currencyName = ""
	public var languages = ""
	public var image: URL?
	public var imagePath2: URL? //<- image_path_2
	public var capitalTimeZone = Timezone()
    
    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try map.decode(Int.self, forKey: .id)
        self.name = try map.decode(String.self, forKey: .name)
        self.code = try map.decode(String.self, forKey: .code)
        self.codeIso = try map.decode(String.self, forKey: .codeIso)
        self.native = try map.decode(String.self, forKey: .native)
        self.phone = try map.decode(Int.self, forKey: .phone)
        self.continent = try map.decode(String.self, forKey: .continent)
        self.capital = try map.decode(String.self, forKey: .capital)
        self.capitalLat = try map.decode(Double.self, forKey: .capitalLat)
        self.capitalLng = try map.decode(Double.self, forKey: .capitalLng)
        self.currency = try map.decode(String.self, forKey: .currency)
        self.currencyName = try map.decode(String.self, forKey: .currencyName)
        self.languages = try map.decode(String.self, forKey: .languages)
        self.image = try map.decode(URL.self, forKey: .image)
        self.imagePath2 = try map.decode(URL.self, forKey: .imagePath2)
        self.capitalTimeZone = try map.decode(Timezone.self, forKey: .capitalTimeZone)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case codeIso = "code_iso"
        case code
        case native
        case phone
        case continent
        case capital
        case capitalLat = "capital_lat"
        case capitalLng = "capital_lng"
        case currency
        case currencyName = "currency_name"
        case languages
        case image
        case imagePath2 = "image_path_2"
        case capitalTimeZone = "capital_time_zone"
    }
}

