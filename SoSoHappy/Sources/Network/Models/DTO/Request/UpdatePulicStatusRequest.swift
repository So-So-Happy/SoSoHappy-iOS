//
//  UpdatePulicStatusRequest.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//


import Foundation


struct UpdatePublicStatusRequest: Encodable {
    let date: Int64
    let nickname: String
}


