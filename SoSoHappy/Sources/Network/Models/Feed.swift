//
//  Feed.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import UIKit

struct Feed: Codable {
    
    let text: String
    let imageList: Data
    let categoryList: [String]
    let isPulic: Bool
    let date: Double
    let weather: String
    let happiness: Int
    let nickName: String
    
    init(text: String,
         imageList: Data,
         categoryList: [String],
         isPublic: Bool,
         date: Double,
         weather: String,
         happiness: Int,
         nickName: String
    ) {
        self.text = text
        self.imageList = imageList
        self.categoryList = categoryList
        self.isPulic = isPublic
        self.date = date
        self.weather = weather
        self.happiness = happiness
        self.nickName = nickName
    }
    
}



