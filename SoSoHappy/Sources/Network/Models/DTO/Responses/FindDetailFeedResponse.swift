//
//  FindDetailFeedResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/16.
//

import UIKit

struct FindDetailFeedResponse: Codable {
    let text: String
    let imageIdList: [Int]
    let categoryList: [String]
    let date: Int64
    let weather: String
    let happiness: Int
    let nickname: String
    let isLiked: Bool

}

extension FindDetailFeedResponse {
    func toDomain() -> UserFeed {
        return .init(nickName: nickname,
                     date: String(date),
                     weather: weather,
                     happiness: happiness,
                     categoryList: categoryList,
                     text: text,
                     imageIdList: imageIdList,
                     isLiked: isLiked)
    }
}
