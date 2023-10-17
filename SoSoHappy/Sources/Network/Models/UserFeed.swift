//
//  UserFeed.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/16.
//


import UIKit

struct UserFeed {
    
    let text: String
    let imageList: [UIImage]
    let categoryList: [String]
    let date: String
    let weather: String
    let happiness: Int
    let nickName: String
    let isLiked: Bool
    
    init(text: String,
         imageList: [UIImage],
         categoryList: [String],
         date: String,
         weather: String,
         happiness: Int,
         nickName: String,
         isLiked: Bool
    ) {
        self.text = text
        self.imageList = imageList
        self.categoryList = categoryList
        self.date = date
        self.weather = weather
        self.happiness = happiness
        self.nickName = nickName
        self.isLiked = isLiked
    }
    
}

extension UserFeed {
    var happyImage: String {
        switch happiness {
        case 1 : return "happy1"
        case 2 : return "happy2"
        case 3: return "happy3"
        case 4: return "happy4"
        default: return "happy5"
        }
    }
}



