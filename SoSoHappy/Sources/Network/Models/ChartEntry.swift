//
//  ChartEntry.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/11/30.
//

import Foundation

struct ChartEntry: Equatable {
    let x: Double
    let y: Double
}

extension ChartEntry {
    static func ==(lhs: ChartEntry, rhs: ChartEntry) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
