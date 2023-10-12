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
        dateformat.dateFormat = "yyyyMM"
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
    
    /// 1분전, 1초전
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "ko_KR")
        let timeAgoString = formatter.localizedString(for: self, relativeTo: Date())
        return timeAgoString == "0초 후" ? "지금" : timeAgoString
    }

}
