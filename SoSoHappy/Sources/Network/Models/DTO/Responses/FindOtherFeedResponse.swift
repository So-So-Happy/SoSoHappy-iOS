//
//  FindOtherFeedResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import UIKit

struct FindOtherFeedResponse: Codable {
    let content: [Content]
    let numberOfElements, pageNumber, pageSize: Int
    let isLast: Bool
}

struct Content: Codable {
    let nickname: String
    let weather: String         // 날씨
    let date: Int64             // 날짜 ex. 2023101922401122
    let happiness: Int          // 행복 정도 ex. 1
    let text: String            // 피드 작성 글
    let categoryList: [String]   // 카테고리 목록  ex. ["youtube", "pet"]
    let imageIdList: [Int]     // 등록한 이미지 ex. []
    let isLiked: Bool           // 좋아요 여부
}

extension Content {
    func toDomain() -> UserFeed {
        return .init(
            nickName: nickname,
            date: String(date),
            weather: weather,
            happiness: happiness,
            categoryList: categoryList,
            text: text,
            imageIdList: imageIdList,
            isLiked: isLiked)
    }
}
