//
//  FindIntroductionRequest.swift
//  SoSoHappy
//
//  Created by Sue on 10/20/23.
//

import Foundation

struct FindIntroductionRequest: Codable {
    let nickname: String
    
    var params: [String : Any] {
        return [ "nickname": self.nickname ]
    }
}

