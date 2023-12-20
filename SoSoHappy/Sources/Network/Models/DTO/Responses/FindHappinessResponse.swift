//
//  FindMonthHappiness.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/30.
//

import Foundation

struct FindMonthHappinessResponse: Decodable {
    let happiness: Double
    let formattedDate: String

}

extension FindMonthHappinessResponse {
    var chartIdx: Double {
        return formattedDate.parsingDayStrToIdx()
    }
    
    func toDomain() -> ChartEntry {
        return .init(x: chartIdx , y: happiness)
    }

}

struct FindYearHappinessResponse: Decodable {
    let happiness: Double
    let formattedDate: String

}

extension FindYearHappinessResponse {
    var chartIdx: Double {
        return formattedDate.parsingMonthStrToIdx()
    }
    
    func toDomain() -> ChartEntry {
        return .init(x: chartIdx , y: happiness)
    }
}
