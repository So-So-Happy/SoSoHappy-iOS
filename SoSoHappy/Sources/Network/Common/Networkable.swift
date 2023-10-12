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
        print("accessProvider start")
        let tokenClosure: (TargetType) -> HeaderType = { _ in
//            guard let identifier = UserDefaults.standard.read(key: .userIdentifier) as? String,
//                  let accessToken = KeychainService.getAccessToken(serviceID: identifier),
//                    let refreshToken = KeychainService.getRefreshToken(serviceID: identifier),
//                    let email = UserDefaults.standard.read(key: .userAccount) as? String
//            else {
////                Logger.debug(error: SocialLoginError.noToken, message: "No Token")
//                return HeaderType(email: "", accessToken: "", refreshToken: "")
//            }
            let accessToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJBY2Nlc3NUb2tlbiIsImV4cCI6MTY5NjY5MTIyNiwiZW1haWwiOiJwa2t5dW5nMjZAZ21haWwuY29tIn0.9FIklq2cX79M99nhdjXHZSiEC9eocps_0Qib4RXjG3xL80PP0ubGNEddqKi-jpdahB42WAhEPM4EAYHj789p-w"
            let refreshToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJSZWZyZXNoVG9rZW4iLCJleHAiOjE3MDg3NTEyMjYsImVtYWlsIjoicGtreXVuZzI2QGdtYWlsLmNvbSJ9.NOGYk-toxpH8tybWFfhakwP1p433PoG66K3vb3SP7GmKlRs03Gt1WuYF-5X34BH_SnHYVf9yXVsrjySycdmWbQ"
            
            let email = "pkkyung26@gmail.com"
            
            return HeaderType(email: email, accessToken: accessToken, refreshToken: refreshToken)
        }
        
        let authPlugin = JWTPlugin(tokenClosure)
//        let loggerPlugin = NetworkLoggerPlugin()
        
        print("accessProvider finish")
        /// plugin객체를 주입하여 provider 객체 생성
        return MoyaProvider<Target>(plugins: [authPlugin])
    }
    
    
    /// login, duplicate 시 사용
    func makeProvider() -> MoyaProvider<Target> {
        
        /// 로그 세팅
        let loggerPlugin = NetworkLoggerPlugin()
        
        return MoyaProvider<Target>(plugins: [loggerPlugin])
    }
}



//extension Networkable {
//    func getAuthPlugin() -> JWTPlugin {
//        let tokenClosure: (TargetType) -> HeaderType = { _ in
//            guard let identifier = UserDefaults.standard.read(key: .userIdentifier) as? String,
//                  let accessToken = Keychain.getAccessToken(serviceID: identifier),
//                    let refreshToken = Keychain.getRefreshToken(serviceID: identifier),
//                    let email = UserDefaults.standard.read(key: .userAccount) as? String
//            else {
////                Logger.debug(error: SocialLoginError.noToken, message: "No Token")
//                return HeaderType(email: "", accessToken: "", refreshToken: "")
//            }
//
//            return HeaderType(email: email, accessToken: accessToken, refreshToken: refreshToken)
//        }
//
//        return JWTPlugin(tokenClosure)
//    }
//}
