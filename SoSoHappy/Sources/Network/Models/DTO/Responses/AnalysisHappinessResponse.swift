//
//  AnalysisHappiness.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct AnalysisHappinessResponse: Codable {
    let bestCategoryList: [String]
    let recommendCategoryList: [String]
}
