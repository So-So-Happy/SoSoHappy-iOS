//
//  duplicationResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/11.
//

import Foundation

struct CheckNickNameResponse: Decodable {
    let email: String
    let isPresent: String // false: 중복 x, true: 중복 o
}
