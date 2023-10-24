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
//            guard let identifier = UserDefaults.standard.read(key: .userIdentifier) as? String,
//                  let accessToken = KeychainService.getAccessToken(serviceID: identifier),
//                    let refreshToken = KeychainService.getRefreshToken(serviceID: identifier),
//                    let email = UserDefaults.standard.read(key: .userAccount) as? String
//            else {
////                Logger.debug(error: SocialLoginError.noToken, message: "No Token")
//                return HeaderType(email: "", accessToken: "", refreshToken: "")
//            }
//            let accessToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJBY2Nlc3NUb2tlbiIsImV4cCI6MTY5NzQ3Mjk0OCwiZW1haWwiOiJwa2t5dW5nMjZAZ21haWwuY29tIn0.KGLF21tjmEc30vUd8v-vTuGToLcpf2_FBou3kGdMIS9YEzvFzMyrUW5xT_WJ__P6r9Cqt5F1M7TBjPJf0GxQZA"
//            let refreshToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJSZWZyZXNoVG9rZW4iLCJleHAiOjE3MDk0NzA5ODEsImVtYWlsIjoicGtreXVuZzI2QGdtYWlsLmNvbSJ9.p_Ong1cGexoarqFG6jCHvriwhncKcGBuzWyH9DFieCm-YlPFpFBYJgpwgLOrLjtqUXUWVAcyZasprT2woPj-SQ"
//            let email = "pkkyung26@gmail.com"
            
            let accessToken = KeychainService.loadData(serviceIdentifier: "sosohappy.tokens", forKey: "accessToken") ?? "없음"
            let refreshToken = KeychainService.loadData(serviceIdentifier: "sosohappy.tokens", forKey: "refreshToken") ?? "없음"
            let userEmail = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "userEmail") ?? "없음"
            return HeaderType(email: userEmail, accessToken: accessToken, refreshToken: refreshToken)
        }
        
        let authPlugin = JWTPlugin(tokenClosure)
//        let loggerPlugin = NetworkLoggerPlugin()
        
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
