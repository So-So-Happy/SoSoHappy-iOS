//
//  Ex+Encodable.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/06.
//

import Foundation

extension Encodable {
    func toDictionary() -> [String: Any] {
        do {
            let jsonEncoder = JSONEncoder()
            let encodedData = try jsonEncoder.encode(self)
            
            let dictionaryData = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any]
            return dictionaryData ?? [:]
        } catch {
            return [:]
        }
    }
}
