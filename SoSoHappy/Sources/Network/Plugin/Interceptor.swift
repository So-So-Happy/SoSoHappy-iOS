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

class Interceptor: RequestInterceptor {
    
    private var disposeBag = DisposeBag()
    
    func adapt() {  }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 403
        else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        let accessToken = KeychainService.getAccessToken()
        let refreshToken = KeychainService.getAccessToken()
        let userEmail = KeychainService.getUserEmail()
        
        let url = "\(Bundle.main.baseURL)\(Bundle.main.reIssueTokenPath)"
        let headers: HTTPHeaders = [
            "Authorization": accessToken,
            "Authorization-refresh": refreshToken,
            "Email": userEmail
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
                        completion(.retry)
                    } else {
                
                    }
                case .failure(let error):
                    completion(.doNotRetryWithError(error))
                }
            }
        
    }
    
}
