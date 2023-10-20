//
//  FindDetailFeed.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/16.
//

import Foundation

struct FindDetailFeedRequest: Encodable {
    let date: Int64
    let dstNickname: String
    let srcNickname: String
    
}
