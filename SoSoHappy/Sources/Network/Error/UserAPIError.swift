//
//  UserAPIError.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/06.
//

import RxSwift
import Moya
import Alamofire
import Then

// MARK: Error Type
enum MyAPIError: Error {
  case empty
  case requestTimeout(Error)
  case internetConnection(Error)
  case restError(Error, statusCode: Int? = nil, errorCode: String? = nil)
  
  var statusCode: Int? {
    switch self {
    case let .restError(_, statusCode, _):
      return statusCode
    default:
      return nil
    }
  }
    
  var errorCodes: [String] {
    switch self {
    case let .restError(_, _, errorCode):
      return [errorCode].compactMap { $0 }
    default:
      return []
    }
  }
    
  var isNoNetwork: Bool {
    switch self {
    case let .requestTimeout(error):
      fallthrough
    case let .restError(error, _, _):
      return UserAPI.isNotConnection(error: error) || UserAPI.isLostConnection(error: error)
    case .internetConnection:
      return true
    default:
      return false
    }
  }
}
