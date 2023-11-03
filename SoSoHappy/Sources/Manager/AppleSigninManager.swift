//
//  AppleSigninManager.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/20.
//

import RxSwift
import AuthenticationServices

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
    
    func resign() -> Observable<Void> {
        return .create { observer in
            observer.onNext(())
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func logout() -> Observable<Void> {
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
            var email = ""
            let emailFromKeychain = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfoapple", forKey: "userEmail")?.split(separator: "+")[0] ?? ""
            
            if emailFromKeychain.isEmpty {
                email = appleIDCredential.email ?? ""
            } else { email = String(emailFromKeychain) }
            print("email", email)
            print("id", appleIDCredential.identityToken?.base64EncodedString() ?? "id")
            let request = SigninRequest(
                email: email,
                provider: "apple",
                providerId: userIdentifier,
                codeVerifier: UserDefaults.standard.string(forKey: "codeVerifier") ?? "unknownCodeVerifier",
                authorizeCode: UserDefaults.standard.string(forKey: "authorizeCode") ?? "unknownAuthorizeCode"
            )
            
            self.publisher.onNext(request)
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
