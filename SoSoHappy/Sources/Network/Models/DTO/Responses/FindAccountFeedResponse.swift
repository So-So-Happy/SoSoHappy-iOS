//
//  FindAccountFeedResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/06.
//

import Foundation
import UIKit


struct FindAccountFeedResponse: Decodable {
    let nickname, weather: String
    let date: Int64
    let happiness: Int
    let text: String
    let isPublic: Bool
    let categoryList: [String]
    let imageList: [String]
    let likeNicknameList: [String]?

}

extension FindAccountFeedResponse {
    func toDomain() -> MyFeed {
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
                     isPublic: isPublic,
                     date: String(date),
                     weather: weather,
                     happiness: happiness,
                     nickName: nickname,
                     likeNickNameList: likeNicknameList ?? [])
    }
}
