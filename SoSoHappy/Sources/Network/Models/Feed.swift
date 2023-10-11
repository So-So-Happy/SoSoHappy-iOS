//
//  Feed.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import UIKit

struct Feed {
    
    let text: String
    let imageList: [UIImage]
    let categoryList: [String]
    let isPulic: Bool
    let date: Double
    let weather: String
    let happiness: Int
    let nickName: String
    
    init(text: String,
         imageList: [UIImage],
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



