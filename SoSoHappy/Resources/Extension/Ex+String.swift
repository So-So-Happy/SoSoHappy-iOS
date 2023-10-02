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
}
