//
//  HappinessRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct HappinessRequest: Codable, Requestable {
    let nickname: String
    let date: Int64
    
    var params: [String : Any] {
        return [
            "nickname": self.nickname,
            "date": self.date
        ]
    }
}
