//
//  FindProfileResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/13.
//

import Foundation

struct FindProfileImgResponse: Decodable {
    let nickName: String
    let profileImg: Data
}
