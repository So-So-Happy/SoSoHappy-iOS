//
//  UpdateLikeRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct UpdateLikeRequest: Codable {
    let srcNickname: String
    let nickname: String
    let date: Int64
}
