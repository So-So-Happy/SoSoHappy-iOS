//
//  LoginResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/11.
//

import Foundation


// body x header 그래서 헤더로 처리를 해야함.
struct AuthResponse: Decodable {
    let Authorization: String // accessToken
    let AuthorizationRefresh: String // refreshToken
    
    enum CodingKeys: String, CodingKey {
        case Authorization = "accessToken"
        case AuthorizationRefresh = "refreshToken"
    }
}

extension AuthResponse {
//    func parsingToken(_ token) -> String {
//        // Bearer 문자열 처리 
//    }
}
