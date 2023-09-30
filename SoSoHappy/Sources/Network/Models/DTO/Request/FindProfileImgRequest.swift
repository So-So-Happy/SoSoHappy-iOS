//
//  findProfileImg.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/13.
//

import Foundation

struct FindProfileImgRequest: Codable {
    let nickName: String
    
    init(nickName: String) {
        self.nickName = nickName
    }
}

