//
//  UpdatePublicStatusRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/05.
//

import Foundation


struct UpdatePublicStatusRequest: Codable {
    let date: Int64
    let nickname: String
}
