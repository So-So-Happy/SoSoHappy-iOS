//
//  FindDayFeedResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct FindFeedResponse: Decodable {
    let nickname, weather: String
    let date, happiness: Int
    let text: String
    let isPublic: Bool
    let categoryList, imageList, likeNicknameList: [String]
    
}
