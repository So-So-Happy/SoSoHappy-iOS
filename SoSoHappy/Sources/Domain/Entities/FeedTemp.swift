//
//  FeedTemp.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/07.
//

/*
- 임시로 데이터 설정해줌
 */

import UIKit


struct FeedTemp: Hashable {
    let profileImage: UIImage           // String?
    let profileNickName: String         // 게시글 작성자 닉네임 - "소해피"
    let time: String                    // 게시글 업로드 시간 - "5분 전"
    var isLike: Bool                    // 좋아요 여부
    let weather: String                 // 날씨
    let date: String                    // 게시글 작성 날짜
    let categories: [String]
    let content: String                 // 게시물 작성 내용
    let images: [UIImage]               // 업로드 이미지
}
