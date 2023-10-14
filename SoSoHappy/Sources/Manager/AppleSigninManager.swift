//
//  AppleSigninManager.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/20.
//

import AuthenticationServices

import RxSwift

final class AppleSigninManager: NSObject, SigninManagerProtocol {
    private var publisher = PublishSubject<SigninRequest>()
    
    deinit {
        self.publisher.onCompleted()
    }
    
    func signin() -> Observable<SigninRequest> {
        self.publisher = PublishSubject<SigninRequest>()
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        authController.delegate = self
        authController.performRequests()
        
        return self.publisher
    }
    
    func signout() -> Observable<Void> {
        // 애플에서는 회원탈퇴 API를 제공하지 않습니다.
        return .create { observer in
            observer.onNext(())
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func logout() -> Observable<Void> {
        // 애플에서는 로그아웃 API를 제공하지 않습니다.
        return .create { observer in
            observer.onNext(())
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}

extension AppleSigninManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let familyName = appleIDCredential.fullName?.familyName
            let givenName = appleIDCredential.fullName?.givenName
            let email = appleIDCredential.email
            let state = appleIDCredential.state
            
            print("🔎 ##### 애플 사용자 정보 조회 성공 #####")
            print("userID:", userIdentifier)
            print("familyName:", familyName ?? "이미 가입된 사용자")
            print("givenName:", givenName ?? "이미 가입된 사용자")
            print("email", email ?? "이미 가입된 사용자")
            print("state", state ?? "이미 가입된 사용자")
            
            self.publisher.onCompleted()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authorizationError = error as? ASAuthorizationError {
            switch authorizationError.code {
            case .canceled:
                self.publisher.onError(BaseError.custom("cancel"))
            case .failed, .invalidResponse, .notHandled, .unknown:
                let error = BaseError.custom(authorizationError.localizedDescription)
                self.publisher.onError(error)
            default:
                let error = BaseError.custom(error.localizedDescription)
                self.publisher.onError(error)
            }
        } else {
            let error = BaseError.custom("error is instance of \(error.self). not ASAuthorizationError")
            self.publisher.onError(error)
        }
    }
}
