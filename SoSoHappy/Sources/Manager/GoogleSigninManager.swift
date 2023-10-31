//
//  GoogleSigninManager.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/19/23.
//

import RxSwift
import GoogleSignIn

final class GoogleSigninManager: SigninManagerProtocol {
    private var disposeBag = DisposeBag()
    private var publisher = PublishSubject<SigninRequest>()
    
    deinit {
        self.publisher.onCompleted()
    }
    
    func signin() -> Observable<SigninRequest> {
        self.publisher = PublishSubject<SigninRequest>()
        
        guard let viewController = UIApplication.getMostTopViewController() else {
            self.publisher.onError(BaseError.unknown)
            return .empty()
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { userInfo, error in
            if let userInfo = userInfo {
                let request = SigninRequest(email: userInfo.user.profile?.email ?? "unknownEmail", provider: "google", providerId: userInfo.user.userID ?? "unknownId", codeVerifier: UserDefaults.standard.string(forKey: "codeVerifier") ?? "unknownCodeVerifier", authorizeCode: UserDefaults.standard.string(forKey: "authorizeCode") ?? "unknownAuthorizeCode")
                
                self.publisher.onNext(request)
                self.publisher.onCompleted()
            } else {
                self.publisher.onError(BaseError.unknown)
            }
        }
        
        return self.publisher
    }
    
    func signout() -> RxSwift.Observable<Void> {
        return .empty()
    }
    
    func logout() -> Observable<Void> {
        return Observable.create { observer in
            GIDSignIn.sharedInstance.signOut()
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
