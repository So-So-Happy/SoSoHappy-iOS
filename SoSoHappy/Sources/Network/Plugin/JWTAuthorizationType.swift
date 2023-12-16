//
//  JWTAuthorizationType.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/07.
//

import Foundation
import Moya

public struct HeaderType {
    let email: String
    let accessToken: String
    let refreshToken: String
}

// MARK: - JWTAuthorizationType
public protocol JWTAuthorizable {
    var authorizationType: JWTAuthorizationType? { get }
}

public enum JWTAuthorizationType {
    case accessToken
    case refreshToken
    
    public var value: [String] {
        switch self {
        case .accessToken:
            return ["Authorization", "email"]
        case .refreshToken:
            return ["Authorization", "Email", "Authorization-refresh"]
        }
    }
}

public final class JWTPlugin: PluginType {

    public typealias TokenClosure = (TargetType) -> HeaderType
    
    public let tokenClosure: TokenClosure
    
    public init(_ tokenClosure: @escaping TokenClosure) {
        self.tokenClosure = tokenClosure
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard
            let authorizable = target as? JWTAuthorizable,
            let authorizationType = authorizable.authorizationType
        else { return request }
        
        var request = request
        
        // accessToken, email 헤더에 추가
        request.addValue(self.tokenClosure(target).accessToken, forHTTPHeaderField: authorizationType.value[0])
        request.addValue(self.tokenClosure(target).email, forHTTPHeaderField: authorizationType.value[1])
        
        // token 재발급시 refreshToken 헤더에 추가
        if authorizationType == .refreshToken {
            request.addValue(self.tokenClosure(target).refreshToken, forHTTPHeaderField: authorizationType.value[2])
        }
        
        return request
    }

}
