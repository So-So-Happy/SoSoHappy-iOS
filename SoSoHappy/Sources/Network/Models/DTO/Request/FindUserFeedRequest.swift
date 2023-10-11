//
//  FindUserFeedRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct FindUserFeedRequest: Codable, Requestable {
    let srcNickname: String
    let dstNickname: Double
    let page: Int
    let size: Int
    
    var params: [String : Any] {
        return [
            "srcNickname": self.srcNickname,
            "dstNickname": self.dstNickname,
            "page": self.page,
            "size": self.size
        ]
    }
    
}
