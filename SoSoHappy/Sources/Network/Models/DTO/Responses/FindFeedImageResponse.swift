//
//  FindFeedImageResponse.swift
//  SoSoHappy
//
//  Created by Sue on 12/8/23.
//

import UIKit

struct FindFeedImageResponse: Decodable {
    let image: String
}

extension FindFeedImageResponse {
    func toDomain() -> UIImage? {
        guard let data = Data(base64Encoded: image, options: .ignoreUnknownCharacters), let uiImage = UIImage(data: data) else { return nil }
        return uiImage
    }
}
