//
//  Feed.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import UIKit

struct MyFeed: FeedType {
    let text: String
    let imageList: [UIImage] = []
    let imageIdList: [Int]
    let categoryList: [String]
    let isPulic: Bool
    let date: String
    let weather: String
    let happiness: Int
    let nickName: String
    let likeNickNameList: [String]

    init(
        text: String = "",
        imageIdList: [Int] = [],
        categoryList: [String] = [],
        isPublic: Bool = false,
        date: String = "",
        weather: String = "",
        happiness: Int = 0,
        nickName: String = "",
        likeNickNameList: [String] = []
    ) {
        self.text = text
        self.imageIdList = imageIdList
        self.categoryList = categoryList
        self.isPulic = isPublic
        self.date = date
        self.weather = weather
        self.happiness = happiness
        self.nickName = nickName
        self.likeNickNameList = likeNickNameList
    }
    
}

extension MyFeed {
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
