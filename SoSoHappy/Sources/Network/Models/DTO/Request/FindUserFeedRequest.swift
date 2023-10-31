//
//  FindUserFeedRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct FindUserFeedRequest: Codable {
    let srcNickname: String
    let dstNickname: String
    let page: Int?
    let size: Int?
}

