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
    static func accessProvider() -> MoyaProvider<Target>
    static func makeProvider() -> MoyaProvider<Target>
}

extension Networkable {

    static func accessProvider() -> MoyaProvider<Target> {
        let tokenClosure: (TargetType) -> HeaderType = { _ in
            guard let identifier = UserDefaults.standard.read(key: .userIdentifier) as? String,
                  let accessToken = Keychain.getAccessToken(serviceID: identifier),
                    let refreshToken = Keychain.getRefreshToken(serviceID: identifier),
                    let email = UserDefaults.standard.read(key: .userAccount) as? String
            else {
//                Logger.debug(error: SocialLoginError.noToken, message: "No Token")
                return HeaderType(email: "", accessToken: "", refreshToken: "")
            }
            
            return HeaderType(email: email, accessToken: accessToken, refreshToken: refreshToken)
        }
        
        let authPlugin = JWTPlugin(tokenClosure)
        let loggerPlugin = NetworkLoggerPlugin()
        
        /// plugin객체를 주입하여 provider 객체 생성
        return MoyaProvider<Target>(plugins: [authPlugin, loggerPlugin])
    }
    
    
    /// login, duplicate 시 사용
    static func makeProvider() -> MoyaProvider<Target> {
        
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
