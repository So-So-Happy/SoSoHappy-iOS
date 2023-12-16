//
//  Interceptor.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/12/15.
//

import UIKit
import Moya
import Alamofire
import RxSwift

class Interceptor : RequestInterceptor {
    
    private var disposeBag = DisposeBag()
    
    func adapt() {  }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("retry 진입")
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 403
        else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        let accessToken = KeychainService.loadData(serviceIdentifier: "sosohappy.tokens", forKey: "accessToken") ?? ""
        let refreshToken = KeychainService.loadData(serviceIdentifier: "sosohappy.tokens", forKey: "refreshToken") ?? ""
        let userEmail = "pkkyung26@gmail.com+google"
        
        let url = "https://sosohappy.dev/auth-service/reIssueToken"
        let headers: HTTPHeaders = [
            "Authorization" : accessToken,
            "Authorization-refresh" : refreshToken,
            "Email" : userEmail
        ]
        
        /// response 에 body 가 비어있고, header에 token 이 내려옴
        /// Alamofire 에서 Body 가 비어있어 에러로 처리
        /// .validate(statusCode: 200..<300) 추가 해서 성공 응답코드 지정해주면 body 가 비어있어도 성공으로 처리해줌
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .response { response in
                switch response.result {
                case .success(_):
                    if let headers = response.response?.allHeaderFields as? [String: String],
                       let accessToken = headers["Authorization"],
                       let refreshToken = headers["authorization-refresh"] {
                        KeychainService.saveData(serviceIdentifier: "sosohappy.tokens", forKey: "accessToken", data: accessToken)
                        KeychainService.saveData(serviceIdentifier: "sosohappy.tokens", forKey: "refreshToken", data: refreshToken)
                        print("토큰 재발급: accessToken: \(accessToken)")
                        print("토큰 재발급: refreshToken: \(refreshToken)")
                        completion(.retry)
                    } else {
                        print("Error: Unable to retrieve tokens from headers.")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion(.doNotRetryWithError(error))
                }
            }
        
    }
    
}

