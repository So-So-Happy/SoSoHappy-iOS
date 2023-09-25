//
//  ServiceError.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/07.
//

public enum HTTPError: Int, Error {
  case badRequest = 400
  case unauthorized = 401
  case forbidden = 403
  case notFound = 404
  case internalServierError = 500
  case badGateway = 502
  case maintenance = 503
}

extension HTTPError {
  public var description: String {
    switch self {
    case .badRequest:
      return "http_error_bad_request"
    case .unauthorized:
      return "http_error_unauthorized"
    case .forbidden:
      return "http_error_forbidden"
    case .notFound:
      return "http_error_not_found"
    case .internalServierError:
      return "http_error_internal_server_error"
    case .badGateway:
      return "http_error_bad_gateway"
    case .maintenance:
      return "http_error_maintenance"
    }
  }
}
