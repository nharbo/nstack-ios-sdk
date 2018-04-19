//
//  Encodable+Dictionary.swift
//  NStackSDK
//
//  Created by Andrei Hogea on 13/04/2018.
//  Copyright © 2018 Nodes ApS. All rights reserved.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
