//
//  Happy.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/17.
//

import Foundation

//year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil,
struct Happy {
    let date: String
    let happinessRate: Int
}

extension Happy {
    var charactor: String {
        switch happinessRate {
        case 20 : return "happy1"
        case 40 : return "happy2"
        default: return "happy3"

        }
    }
}

enum HappyRate {
    
    
}
