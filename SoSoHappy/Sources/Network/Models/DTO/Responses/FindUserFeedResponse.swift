//
//  FindUserFeedResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct FindUserFeedResponse: Codable {
    let content: [Content]
    let numberOfElements, pageNumber, pageSize: Int
    let isLast: Bool
}
