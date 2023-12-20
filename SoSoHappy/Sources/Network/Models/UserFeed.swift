//
//  UserFeed.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/16.
//

import UIKit

struct UserFeed: FeedType, Equatable {
    var profileImage: UIImage? = UIImage(named: "profile")
    var selfIntro: String? = nil
    let nickName: String
    let date: String
    let weather: String
    let happiness: Int
    let categoryList: [String]
    let text: String
    var imageList: [UIImage] = []
    var isLiked: Bool
    let imageIdList: [Int]
    
    init(nickName: String, 
         date: String,
         weather: String,
         happiness: Int,
         categoryList: [String],
         text: String,
         imageIdList: [Int],
         isLiked: Bool
    ) {
        self.nickName = nickName
        self.date = date
        self.weather = weather
        self.happiness = happiness
        self.categoryList = categoryList
        self.text = text
        self.imageIdList = imageIdList
        self.isLiked = isLiked
    }
    
    static func == (lhs: UserFeed, rhs: UserFeed) -> Bool {
        return lhs.profileImage?.isEqual(rhs.profileImage) ?? true &&
               lhs.nickName == rhs.nickName &&
               lhs.nickName == rhs.nickName &&
               lhs.date == rhs.date &&
               lhs.weather == rhs.weather &&
               lhs.happiness == rhs.happiness &&
               lhs.categoryList == rhs.categoryList &&
               lhs.text == rhs.text &&
               lhs.isLiked == rhs.isLiked &&
               lhs.imageIdList == rhs.imageIdList
       }
}

extension UserFeed {
    // MARK: 몇분 전
    var timeAgoString: String {
        return dateToDateType.timeAgo()
    }
    
    // MARK: 프로필 이미지 넣은 UserFeed 만들어주는 메서드
    func with(profileImage: UIImage) -> UserFeed {
        var updatedFeed = self
        updatedFeed.profileImage = profileImage
        return updatedFeed
    }
}
