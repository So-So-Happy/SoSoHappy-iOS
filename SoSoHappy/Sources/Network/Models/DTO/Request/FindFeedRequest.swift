//
//  FindDayFeedRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct FindFeedRequest: Codable {
    let date: Int64
    let nickName: String
}
