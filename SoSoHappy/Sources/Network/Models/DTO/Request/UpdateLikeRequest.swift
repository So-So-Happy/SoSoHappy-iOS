//
//  UpdateLikeRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation


struct UpdateLikeRequest: Requestable, Encodable {
    let srcNickname: String
    let nickname: String
    let date: Int64
    
    var params: [String : Any] {
        return [
            "srcNickname": self.srcNickname,
            "nickname": self.nickname,
            "date": self.date
        ]
    }
}
