//
//  LoginResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/11.
//

import Foundation


struct AuthResponse: Decodable {
    let Authorization: String
    let AuthorizationRefresh: String
    
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
