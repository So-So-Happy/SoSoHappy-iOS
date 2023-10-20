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
    let nickname, weather: String //
    let date: Int64 //
    let happiness: Int //
    let text: String //
    let categoryList, imageList: [String] //
    let isLiked: Bool //
}

extension Content {
    func toDomain() -> UserFeed {
        let uiImageList: [UIImage] = imageList.compactMap { image in
            guard let data = Data(base64Encoded: image, options: .ignoreUnknownCharacters),
                  let uiImage = UIImage(data: data) else {
                return nil
            }
            return uiImage
        }

        return .init(
            text: text,
            imageList: uiImageList,
            categoryList: categoryList,
            date: String(date),
            weather: weather,
            happiness: happiness,
            nickName: nickname,
            isLiked: isLiked)
    }
}
