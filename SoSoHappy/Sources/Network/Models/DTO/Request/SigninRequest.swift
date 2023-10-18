//
//  SigninRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/20.
//

import Foundation

struct SigninRequest: Codable {
    let email: String
    let provider: String
    let providerId: String
    let codeVerifier: String
    let authorizeCode: String
}
