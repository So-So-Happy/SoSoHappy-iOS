//
//  Moya+NetworkError.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/04.
//

import Moya
import Alamofire

extension TargetType {
    static func converToURLError(_ error: Error) -> URLError? {
        switch error {
        case let MoyaError.underlying(afError as AFError, _):
            fallthrough
        case let afError as AFError:
            return afError.underlyingError as? URLError
        case let MoyaError.underlying(urlError as URLError, _) :
            fallthrough
        case let urlError as URLError:
            return urlError
        default:
            return nil
        }
    }
    
    /// 오류: 인터넷 연결이 없는 상태
    static func isNotConnection(error: Error) -> Bool {
        converToURLError(error)?.code == .notConnectedToInternet
    }
    
    /// 오류: 네트워크 연결이 끊긴 상태
    static func isLostConnection(error: Error) -> Bool {
        switch error {
        case let AFError.sessionTaskFailed(error: posixError as POSIXError)
            where posixError.code == .ECONNABORTED:
            break
        case let MoyaError.underlying(urlError as URLError, _):
            fallthrough
        case let urlError as URLError:
            guard urlError.code == URLError.networkConnectionLost else { fallthrough }
            break
        default:
            return false
        }
        return true
    }
}
