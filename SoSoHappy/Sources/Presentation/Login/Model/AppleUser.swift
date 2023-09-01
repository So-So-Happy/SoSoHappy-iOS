//
//  AppleUser.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/31.
//

import Foundation
import AuthenticationServices

struct AppleUser {
    let userId: String
    let email: String?
    
    init(credential: ASAuthorizationAppleIDCredential) {
        self.userId = credential.user
        self.email = credential.email
    }
}
