//
//  FeedType.swift
//  SoSoHappy
//
//  Created by Sue on 10/19/23.
//

import UIKit

protocol FeedType {
    var nickName: String { get }
    var weather: String { get }
    var date: String { get }
    var happiness: Int { get }
    var categoryList: [String] { get }
    var text: String { get }
    var imageList: [UIImage] { get }
}

extension FeedType {
    // MARK: 행복 이미지 이름
    var happinessImageName: String {
        switch happiness {
        case 1 : return "happy1"
        case 2 : return "happy2"
        case 3: return "happy3"
        case 4: return "happy4"
        default: return "happy5"
        }
    }
    
    // MARK: CategoryStackView에 바로 사용할 수 있도록 행복 + 카테고리  (ex. ["happy", "youtube"])
    var happinessAndCategoryArray: [String] {
        return [happinessImageName] + categoryList
    }
    
    // MARK: Date 타입으로 변환
    var dateToDateType: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssSS"
        
        if let date = dateFormatter.date(from: date) {
            print("UserFeed - dateToDateType parsed date : \(date)")
            return date
        } else {
            print("UserFeed - dateToDateType failed to parse date")
            return Date()
        }
    }
    
    // MARK: 2023.10.19 토요일
    var dateFormattedString: String {
        return dateToDateType.getFormattedYMDE()
    }
    
    var dateFormattedInt64: Int64 {
        return dateToDateType.getFormattedYMDH()
    }
}
