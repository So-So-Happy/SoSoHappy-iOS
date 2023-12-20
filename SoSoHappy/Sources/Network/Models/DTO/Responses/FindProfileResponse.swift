//
//  FindProfileResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/13.
//

import UIKit

struct FindProfileImgResponse: Decodable {
    let nickname: String
    let profileImg: String
}

extension FindProfileImgResponse {
    func toDomain() -> UIImage {
        guard let data = Data(base64Encoded: profileImg, options: .ignoreUnknownCharacters), let uiImage = UIImage(data: data) else {
            return UIImage(named: "profile")!
        }
        
        return uiImage
    }
}
