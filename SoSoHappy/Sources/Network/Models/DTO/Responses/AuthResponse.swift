//
//  LoginResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/11.
//

import Foundation


// body x header 그래서 헤더로 처리를 해야함.
struct AuthResponse: Decodable {
    let authorization: String // accessToken
    let authorizationRefresh: String // refreshToken
    let email: String
    let nickName: String
}

struct NickNameResponse: Decodable {
    let nickname: String
}
