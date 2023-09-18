//
//  ServiceError.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/07.
//

import Foundation
import Moya

// 400: badrequest(조회 안함 size 25 초과)
// 403: Forbidden(JWT 인증실패)
// 500: Internal Server Error(서버 오류)


// back-end 팀과 정의한 에러 내용
enum ServiceError: Error {
    case moyaError(MoyaError)
    case invalidResponse(responseCode: Int, message: String)
    case tokenExpired
    case refreshTokenExpired
    case duplicateLoggedIn(message: String)
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .moyaError(let moyaError):
            return moyaError.localizedDescription
        case let .invalidResponse(_, message):
            return message
        case .tokenExpired:
            return "AccessToken Expired"
        case .refreshTokenExpired:
            return "RefreshToken Expired"
        case let .duplicateLoggedIn(message):
            return message
        }
    }
}
