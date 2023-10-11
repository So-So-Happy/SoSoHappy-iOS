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
}
