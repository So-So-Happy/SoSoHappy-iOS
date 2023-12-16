//
//  ReIssueTokenResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/12/15.
//

import Foundation

struct RelssueTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "Authorization"
        case refreshToken = "Authorization-Refresh"
    }
}
