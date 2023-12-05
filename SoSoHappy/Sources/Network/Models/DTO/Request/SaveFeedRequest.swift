//
//  SaveFeedRequest.swift
//  SoSoHappy
//
//  Created by Sue on 11/5/23.
//

import UIKit

struct SaveFeedRequest: Codable {
    let text: String
    let imageList: [Data]?
    let categoryList: [String]
    let isPublic: Bool
    let date: Int64
    let weather: String
    let happiness: Int
    let nickname: String

    init(text: String, images: [UIImage]?, categoryList: [String], isPublic: Bool, date: Int64, weather: String, happiness: Int, nickname: String) {
        self.text = text
        self.categoryList = categoryList
        self.isPublic = isPublic
        self.date = date
        self.weather = weather
        self.happiness = happiness
        self.nickname = nickname

        self.imageList = images?.compactMap({ image in
            return image.pngData()
        })
    }
}



