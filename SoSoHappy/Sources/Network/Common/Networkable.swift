//
//  Networkable.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/06.
//

import Moya

protocol Networkable {
    /// provider객체 생성 시 Moya에서 제공하는 TargetType을 명시해야 하므로 타입 필요
    associatedtype Target: TargetType
    /// DIP를 위해 protocol에 provider객체를 만드는 함수 정의
    func accessProvider() -> MoyaProvider<Target>
    func makeProvider() -> MoyaProvider<Target>
}

extension Networkable {

    func accessProvider() -> MoyaProvider<Target> {
        let tokenClosure: (TargetType) -> HeaderType = { _ in

            let accessToken = KeychainService.getAccessToken()
            let refreshToken = KeychainService.getRefreshToken()
            let userEmail = KeychainService.getUserEmail()
            
            return HeaderType(email: userEmail, accessToken: accessToken, refreshToken: refreshToken)
        }
        
        let authPlugin = JWTPlugin(tokenClosure)
        
        return MoyaProvider<Target>(
            session: Moya.Session(interceptor: Interceptor()),
            plugins: [authPlugin]
        )
    }
    
    /// login, duplicate 시 사용
    func makeProvider() -> MoyaProvider<Target> {
        
        /// 로그 세팅
        let loggerPlugin = NetworkLoggerPlugin()
        
        return MoyaProvider<Target>(plugins: [loggerPlugin])
    }
}
