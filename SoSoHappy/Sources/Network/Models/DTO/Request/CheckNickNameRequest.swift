//
//  CheckNickNameRequest.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/22/23.
//

import Foundation

struct CheckNickNameRequest: Codable, Requestable {
    let nickName: String
    
    var params: [String: Any] {
        let parameters: [String: Any] = [
            "nickname": nickName
        ]

        return parameters
    }
}
