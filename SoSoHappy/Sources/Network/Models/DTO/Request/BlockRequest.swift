//
//  BlockRequest.swift
//  SoSoHappy
//
//  Created by Sue on 1/4/24.
//

import Foundation

struct BlockRequest: Codable {
    let srcNickname: String // 유저 닉네임
    let dstNickname: String // 차단할 유저 닉네임
}
