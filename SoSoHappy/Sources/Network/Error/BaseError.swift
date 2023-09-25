//
//  BaseError.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/20.
//


import Foundation

enum BaseError: LocalizedError {
    case custom(String)
    case unknown
    case timeout
    case failDecoding
    case nilValue
    case errorContainer(ResponseContainer<String>)

    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
        case .unknown:
            return "error_unknown"
        case .timeout:
            return "http_error_timeout"
        case .failDecoding:
            return "error_failed_to_json"
        case .nilValue:
            return "error_value_is_nil"
        case .errorContainer(let errorContainer):
            return errorContainer.message
        }
    }
}
