//
//  KakaoSigninManager.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/19/23.
//

import RxSwift
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import RxKakaoSDKUser
import RxKakaoSDKAuth
import RxKakaoSDKCommon

final class KakaoSigninManager: SigninManagerProtocol {
    private var disposeBag = DisposeBag()
    private var publisher = PublishSubject<SigninRequest>()
    
    deinit {
        self.publisher.onCompleted()
    }
    
    func signin() -> Observable<SigninRequest> {
        self.publisher = PublishSubject<SigninRequest>()
        
        if UserApi.isKakaoTalkLoginAvailable() {
            self.signInWithKakaoTalk()
        } else {
            self.signInWithKakaoAccount()
        }
        return self.publisher
    }
    
    func resign() -> Observable<Void> {
        return .create { observer in
            UserApi.shared.unlink { error in
                if let kakaoError = error as? SdkError,
                   kakaoError.getApiError().reason == .InvalidAccessToken {
                    observer.onNext(())
                    observer.onCompleted()
                } else if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
    }
    
    func logout() -> Observable<Void> {
        return .create { observer in
            UserApi.shared.logout { error in
                if let kakaoError = error as? SdkError,
                   kakaoError.getApiError().reason == .InvalidAccessToken {
                    observer.onNext(())
                    observer.onCompleted()
                } else if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    private func signInWithKakaoTalk() {
        UserApi.shared.loginWithKakaoTalk { authToken, error in
            if let error = error {
                if let sdkError = error as? SdkError {
                    if sdkError.isClientFailed {
                        switch sdkError.getClientError().reason {
                        case .Cancelled:
                            self.publisher.onError(BaseError.custom("cancel"))
                        default:
                            let errorMessage = sdkError.getApiError().info?.msg ?? ""
                            let error = BaseError.custom(errorMessage)
                            
                            self.publisher.onError(error)
                        }
                    }
                } else {
                    let signInError
                    = BaseError.custom("error is not SdkError. (\(error.self))")
                    
                    self.publisher.onError(signInError)
                }
            } else {
                guard authToken != nil else {
                    self.publisher.onError(BaseError.custom("authToken is nil"))
                    return
                }
                self.getUserInfo()
            }
        }
    }
    
    private func signInWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { authToken, error in
            if let error = error {
                if let sdkError = error as? SdkError {
                    if sdkError.isClientFailed {
                        switch sdkError.getClientError().reason {
                        case .Cancelled:
                            let error = BaseError.custom("cancel")
                            
                            self.publisher.onError(error)
                        default:
                            let errorMessage = sdkError.getApiError().info?.msg ?? ""
                            let error = BaseError.custom(errorMessage)
                            
                            self.publisher.onError(error)
                        }
                    }
                } else {
                    let signInError
                    = BaseError.custom("error is not SdkError. (\(error.self))")
                    
                    self.publisher.onError(signInError)
                }
            } else {
                guard authToken != nil else {
                    self.publisher.onError(BaseError.custom("authToken is nil"))
                    return
                }
                self.getUserInfo()
            }
        }
    }
    
    // MARK: - 사용자 정보 가져오기
    func getUserInfo() {
        UserApi.shared.rx.me()
            .subscribe (onSuccess:{ user in
                let request = SigninRequest(
                    email: user.kakaoAccount?.email ?? "unknownEmail",
                    provider: "kakao",
                    providerId: String(user.id ?? 0),
                    codeVerifier: UserDefaults.standard.string(forKey: "codeVerifier") ?? "unknownCodeVerifier",
                    authorizeCode: UserDefaults.standard.string(forKey: "authorizeCode") ?? "unknownAuthorizeCode", authorizationCode: "", deviceToken: UserDefaults.standard.string(forKey: "fcmToken") ?? "unknownFcmToken"
                )
                
                self.publisher.onNext(request)
                self.publisher.onCompleted()
            }, onFailure: { error in
                self.publisher.onError(error)
            })
            .disposed(by: disposeBag)
    }
}
