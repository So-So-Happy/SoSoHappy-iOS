//
//  FindOtherFeedResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//


import Foundation

struct FindOtherFeedResponse: Codable {
    let content: [Content]
    let numberOfElements, pageNumber, pageSize: Int
    let isLast: Bool
}

struct Content: Codable {
    let nickname, weather: String
    let date: Double
    let happiness: Int
    let text: String
    let categoryList, imageList: [String]
    let isLiked: Bool
}

