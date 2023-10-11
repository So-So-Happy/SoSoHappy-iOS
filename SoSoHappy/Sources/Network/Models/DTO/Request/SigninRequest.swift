//
//  SigninRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/20.
//

import Foundation

struct SigninRequest: Requestable {
    let socialType: SocialType
    let token: String

    var params: [String : Any] {
        return [
            "socialType": self.socialType.value,
            "token": self.token
        ]
    }
}
