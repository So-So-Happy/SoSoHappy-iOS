//
//  saveFeedResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation


struct SaveFeedResponse: Decodable {
    let success: Bool
    let message: String? // "등록 성공" or null
}

