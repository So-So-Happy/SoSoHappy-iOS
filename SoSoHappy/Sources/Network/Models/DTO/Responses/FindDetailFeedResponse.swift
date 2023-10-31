//
//  FindDetailFeedResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/16.
//

import UIKit

struct FindDetailFeedResponse: Codable {
    let text: String
    let imageList: [String]
    let categoryList: [String]
    let date: Int64
    let weather: String
    let happiness: Int
    let nickname: String
    let isLiked: Bool

}

extension FindDetailFeedResponse {
    func toDomain() -> UserFeed {
        let uiImageList: [UIImage] = imageList.compactMap { image in
            guard let data = Data(base64Encoded: image, options: .ignoreUnknownCharacters),
                  let uiImage = UIImage(data: data) else {
                return nil
            }
            return uiImage
        }
        
        return .init(text: text,
                     imageList: uiImageList,
                     categoryList: categoryList,
                     date: String(date),
                     weather: weather,
                     happiness: happiness,
                     nickName: nickname,
                     isLiked: isLiked)
    }
}
