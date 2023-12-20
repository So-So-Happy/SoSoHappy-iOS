//
//  Ex+String.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/14.
//

import Foundation

extension String {
    //MARK: 뒤에 위치한 공백 제거
    func trimTrailingWhitespaces() -> String {
        return self.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }
    
    /// format: yyyyMMddHHmmssSS -> yyyy년 MM월 dd일 HH시 mm분
    func getDate() -> String {

        // 입력으로 받은 날짜 문자열 (yyyyMMddHHmmssSS 형식)
        let dateString = "2023100512345678"

        // DateFormatter를 생성하고 입력 형식을 설정
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMddHHmmssSS"

        // 입력 문자열을 Date로 파싱
        if let date = inputFormatter.date(from: dateString) {
            // 출력 형식을 설정 (yyyy년 MM월 dd일 HH시 mm분)
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"

            // Date를 출력 문자열로 변환
            let formattedDate = outputFormatter.string(from: date)
            return formattedDate
        } else {
            return ""
        }

    }
    
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"

        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return Date()
        }
    }
    
    func makeData() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssSS"
        
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return Date()
        }
    }
}

extension String {
    // MARK: 문자열 암호화
    func sha512() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha512()
        }
        return ""
    }
    
    // MARK: 랜덤 문자열 생성
    static func createRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String(
            (0..<length)
                .map { _ in letters.randomElement()! }
        )
    }
    
    // MARK: 차트 데이터 formattedDate(ex. "Jan")를 차트에서 사용할 수 있는 Double 형태로 파싱
    func parsingMonthStrToIdx() -> Double {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        let monthDict: [String: Double] = Dictionary(uniqueKeysWithValues: zip(months, stride(from: 0.0, to: 12.0, by: 1.0)))
        
        if let idx = monthDict[self] {
            return idx
        } else {
            return 0.0
        }
    }
    
    // MARK: 차트 데이터 formattedDate(ex. "1")를 차트에서 사용할 수 있는 Double 형태로 파싱
    func parsingDayStrToIdx() -> Double {
        return Double(self) ?? 0.0
    }
}
