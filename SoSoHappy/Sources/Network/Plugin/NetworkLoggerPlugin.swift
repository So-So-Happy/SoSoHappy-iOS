//
//  NetworkLoggerPlugin.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/06.
//

import Moya

struct NetworkLoggerPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            print("[HTTP Request] invalid request")
            return
        }
        
        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "unknown method"
        
        /// HTTP Request Summary
        var httpLog = """
                [HTTP Request]
                URL: \(url)
                TARGET: \(target)
                METHOD: \(method)\n
                """
        
        /// HTTP Request Header
        httpLog.append("HEADER: [\n")
        httpRequest.allHTTPHeaderFields?.forEach {
            httpLog.append("\t\($0): \($1)\n")
        }
        httpLog.append("]\n")
        
        /// HTTP Request Body
        if let body = httpRequest.httpBody, let bodyString = String(bytes: body, encoding: String.Encoding.utf8) {
            httpLog.append("BODY: \n\(bodyString)\n")
        }
        httpLog.append("[HTTP Request End]")
        
        print(httpLog)
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            onSuceed(response, target: target, isFromError: false)
        case let .failure(error):
            onFail(error, target: target)
        }
    }
    
    func onSuceed(_ response: Response, target: TargetType, isFromError: Bool) {
        let request = response.request
        let url = request?.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode
        
        /// HTTP Response Summary
        var httpLog = """
                [HTTP Response]
                TARGET: \(target)
                URL: \(url)
                STATUS CODE: \(statusCode)\n
                """
        
        /// HTTP Response Header
        httpLog.append("HEADER: [\n")
        response.response?.allHeaderFields.forEach {
            httpLog.append("\t\($0): \($1)\n")
        }
        httpLog.append("]\n")
        
        /// HTTP Response Data
        httpLog.append("RESPONSE DATA: \n")
        if let responseString = String(bytes: response.data, encoding: String.Encoding.utf8) {
            httpLog.append("\(responseString)\n")
        }
        httpLog.append("[HTTP Response End]")
        
        print(httpLog)
    }
        //        // 🔥 401 인 경우 리프레쉬 토큰 + 액세스 토큰 을 가지고 갱신 시도.
        //        switch statusCode {
        //        case 401:
        //            let acessToken = UserDefaults.standard.string(forKey: Const.UserDefaultsKey.accessToken)
        //            let refreshToken = UserDefaults.standard.string(forKey: Const.UserDefaultsKey.refreshToken)
        //            // 🔥 토큰 갱신 서버통신 메서드.
        //            userTokenReissueWithAPI(request: UserReissueToken(accessToken: acessToken ?? "",
        //                                                              refreshToken: refreshToken ?? ""))
        //        default:
        //            return
        //        }
        //    }
        
        func onFail(_ error: MoyaError, target: TargetType) {
            if let response = error.response {
                onSuceed(response, target: target, isFromError: true)
                return
            }
            
            /// HTTP Error Summary
            var httpLog = """
                [HTTP Error]
                TARGET: \(target)
                ERRORCODE: \(error.errorCode)\n
                """
            httpLog.append("MESSAGE: \(error.failureReason ?? error.errorDescription ?? "unknown error")\n")
            httpLog.append("[HTTP Error End]")
            
            print(httpLog)
        }
    }
    
    
    // 🔥 Network.
    //extension MoyaLoggerPlugin {
    //    func userTokenReissueWithAPI(request: UserReissueToken) {
    //        UserAPI.shared.userTokenReissue(request: request) { response in
    //            switch response {
    //            case .success(let data):
    //                // 🔥 성공적으로 액세스 토큰, 리프레쉬 토큰 갱신.
    //                if let tokenData = data as? UserReissueToken {
    //                    UserDefaults.standard.set(tokenData.accessToken, forKey: Const.UserDefaultsKey.accessToken)
    //                    UserDefaults.standard.set(tokenData.refreshToken, forKey: Const.UserDefaultsKey.refreshToken)
    //
    //                    print("userTokenReissueWithAPI - success")
    //                }
    //            case .requestErr(let statusCode):
    //                // 🔥 406 일 경우, 리프레쉬 토큰도 만료되었다고 판단.
    //                if let statusCode = statusCode as? Int, statusCode == 406 {
    //                    // 🔥 로그인뷰로 화면전환. 액세스 토큰, 리프레쉬 토큰, userID 삭제.
    //                    let loginVC = UIStoryboard(name: Const.Storyboard.Name.login, bundle: nil).instantiateViewController(withIdentifier: Const.ViewController.Identifier.loginViewController)
    //                    UIApplication.shared.windows.first {$0.isKeyWindow}?.rootViewController = loginVC
    //
    //                    UserDefaults.standard.removeObject(forKey: Const.UserDefaultsKey.accessToken)
    //                    UserDefaults.standard.removeObject(forKey: Const.UserDefaultsKey.refreshToken)
    //                    UserDefaults.standard.removeObject(forKey: Const.UserDefaultsKey.userID)
    //                }
    //                print("userTokenReissueWithAPI - requestErr: \(statusCode)")
    //            case .pathErr:
    //                print("userTokenReissueWithAPI - pathErr")
    //            case .serverErr:
    //                print("userTokenReissueWithAPI - serverErr")
    //            case .networkFail:
    //                print("userTokenReissueWithAPI - networkFail")
    //            }
    //        }
    //    }
    //}

