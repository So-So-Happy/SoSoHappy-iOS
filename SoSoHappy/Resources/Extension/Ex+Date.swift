//
//  Ex+Date.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/18.
//

import Foundation

extension Date {
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "ko_KR")
        dateformat.timeZone = TimeZone(abbreviation: "KST")
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
    
    /// format: yyyy-MM-dd
    func getFormattedDefault() -> String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "ko_KR")
        dateformat.timeZone = TimeZone(abbreviation: "KST")
        dateformat.dateFormat = "yyyy-MM-dd"
        return dateformat.string(from: self)
    }
    
    /// format: yyyy.MM.dd E요일
    func getFormattedYMDE() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ko_KR")
        formatter.dateFormat = "yyyy.MM.dd E요일"
        let convertStr = formatter.string(from: self)
        return convertStr
    }
    
    /// format: yyMMdd
    func getFormattedYMD() -> String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "ko_KR")
        dateformat.timeZone = TimeZone(abbreviation: "KST")
        dateformat.dateFormat = "yyyyMMdd"
        return dateformat.string(from: self)
    }
    
    /// format: yyMM
    func getFormattedYM() -> String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "ko_KR")
        dateformat.timeZone = TimeZone(abbreviation: "KST")
        dateformat.dateFormat = "yyyy.MM"
        return dateformat.string(from: self)
    }

    /// format: yyyyMMddHHmmssSS
    func getFormattedYMDH() -> Int64 {
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "ko_KR")
        dateformat.timeZone = TimeZone(abbreviation: "KST")
        dateformat.dateFormat = "yyyyMMddHHmmssSS"
        let formattedString = dateformat.string(from: self)
        let formattedInt = Int64(formattedString) ?? 0
        
        return formattedInt
    }
    
    func parsingDate(_ string: String) -> String {
        return string
    }
    
    /// 1분전, 1초전
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "ko_KR")
        let timeAgoString = formatter.localizedString(for: self, relativeTo: Date())
        return timeAgoString == "0초 후" ? "지금" : timeAgoString
    }
    
    func moveToNextMonth() -> Date {
        let calendar = Calendar.current
        var nextPage = calendar.date(byAdding: .month, value: 1, to: self) ?? Date()
        
//        if calendar.component(.year, from: nextPage) != calendar.component(.year, from: self) {
//            nextPage = calendar.date(bySetting: .year, value: calendar.component(.year, from: self), of: nextPage) ?? Date()
//        }
        
        return nextPage
    }
    
    func moveToPreviousMonth() -> Date {
        let calendar = Calendar.current
        var previousPage = calendar.date(byAdding: .month, value: -1, to: self) ?? Date()
        
//        if calendar.component(.year, from: previousPage) != calendar.component(.year, from: self) {
//            previousPage = calendar.date(bySetting: .year, value: calendar.component(.year, from: self), of: previousPage) ?? Date()
//        }
        
        return previousPage
    }
 
    func moveToNextYear() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .year, value: 1, to: self) ?? Date()
    }
    
    func moveToPreviousYear() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .year, value: -1, to: self) ?? Date()
    }
    
    func setGraphXaxis() -> [String] {
        var days: [String] = []

        // 현재 달력을 가져옵니다.
        let calendar = Calendar.current

        // 현재 달의 첫 번째 날을 가져옵니다.
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) else {
            fatalError("Failed to get the first day of the month.")
        }

        // 현재 달의 마지막 날을 가져옵니다.
        guard let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth) else {
            fatalError("Failed to get the last day of the month.")
        }

        // 현재 달의 모든 날짜를 가져옵니다.
        var currentDateInLoop = firstDayOfMonth
        while currentDateInLoop <= lastDayOfMonth {
            days.append(String(calendar.component(.day, from: currentDateInLoop)))
            currentDateInLoop = calendar.date(byAdding: .day, value: 1, to: currentDateInLoop)!
        }
        
        return days
    }
    
    
}
