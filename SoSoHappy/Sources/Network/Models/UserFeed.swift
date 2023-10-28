//
//  UserFeed.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/16.
//


import UIKit

// MARK: profileImage 임시로 넣어놓음
struct UserFeed: FeedType, Equatable {
    var profileImage: UIImage? = UIImage(named: "profile")    // 프로필 이미지
    var selfIntro: String? = nil
    let nickName: String                // 닉네임
    let date: String                    // 날짜 ex. "2023101922401122"
    let weather: String                 // 날씨
    let happiness: Int                  // 행복 정도
    let categoryList: [String]          // 카테고리 목록
    let text: String                    // 피드 작성 글
    let imageList: [UIImage]            // 등록한 이미지
    let isLiked: Bool                   // 좋아요
    
    init(nickName: String, 
         date: String,
         weather: String,
         happiness: Int,
         categoryList: [String],
         text: String,
         imageList: [UIImage],
         isLiked: Bool
    ) {
        self.nickName = nickName
        self.date = date
        self.weather = weather
        self.happiness = happiness
        self.categoryList = categoryList
        self.text = text
        self.imageList = imageList
        self.isLiked = isLiked
    }
}

extension UserFeed {
    // MARK: 18분 전
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



