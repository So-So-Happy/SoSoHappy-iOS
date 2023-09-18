//
//  LoginViewReactor.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/09/01.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import RxKakaoSDKAuth
import RxKakaoSDKUser
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn

class LoginViewReactor: Reactor {
    
    // MARK: - 초기 상태를 정의합니다.
    let initialState = State()
    
    // MARK: - Class member property
    let disposeBag = DisposeBag()
    
    // MARK: - 가능한 액션을 정의합니다.
    enum Action {
        case kakaoLogin
        case googleLogin
    }
    
    // MARK: - 액션에 대응하는 변이를 정의합니다. (처리 단위)
    enum Mutation {
        case kakaoLogin
        case googleLogin
        case kakaoLoading(Bool)
        case googleLoading(Bool)
    }
    
    // MARK: - 뷰의 상태를 정의합니다. (현재 상태 기록)
    struct State {
        var isKakaoLoggedIn = false
        var isKakaoLoading = false
        var isGoogleLoggedIn = false
        var isGoogleLoading = false
    }
    
    // MARK: - 액션에서 변이로의 로직을 구현합니다. (Action이 들어온 경우, 어떤 처리를 할건지 분기)
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoLogin:
            // 여기에서 비동기 작업을 수행하고 해당하는 변이를 방출합니다.
            // 예: 실제 로그인 요청 및 결과에 따른 변이 방출
            return Observable.concat([
                Observable.just(Mutation.kakaoLoading(true)),
                Observable.deferred {
                    Observable.create { observer in
                        // Check the availability of Kakao Talk
                        if (UserApi.isKakaoTalkLoginAvailable()) {
                            UserApi.shared.rx.loginWithKakaoTalk()
                                .subscribe(onNext:{ (oauthToken) in
                                    print("loginWithKakaoTalk() success.")
                                    
                                    // 로그인 성공 시 Mutation.login 값 방출
                                    observer.onNext(.kakaoLogin)
                                    
                                    // 성공 시 사용자 정보 가져오기
                                    self.getUserInfo()
                                    
                                    // 이벤트 방출 후 Observable 작업 완료. 더 이상 값 방출 X
                                    observer.onCompleted()
                                    
                                    _ = oauthToken
                                }, onError: {error in
                                    print("loginWithKakaoTalk() error :", error)
                                    observer.onNext(.kakaoLoading(false))
                                    observer.onError(error)
                                })
                                .disposed(by: self.disposeBag)
                            
                        } else { // If you don't have Kakaotalk installed
                            UserApi.shared.rx.loginWithKakaoAccount()
                                .subscribe(onNext:{ (oauthToken) in
                                    print("loginWithKakaoAccount() success.")
                                    
                                    // 로그인 성공 시 Mutation.login 값 방출
                                    observer.onNext(.kakaoLogin)
                                    
                                    // 성공 시 사용자 정보 가져오기
                                    self.getUserInfo()
                                    
                                    // 이벤트 방출 후 Observable 작업 완료. 더 이상 값 방출 X
                                    observer.onCompleted()
                                    
                                    _ = oauthToken
                                }, onError: {error in
                                    print("loginWithKakaoAccount() error :", error)
                                    observer.onNext(.kakaoLoading(false))
                                    observer.onError(error)
                                })
                                .disposed(by: self.disposeBag)
                        }
                        
                        return Disposables.create()
                    } as! Observable<LoginViewReactor.Mutation>
                },
                Observable.just(Mutation.kakaoLoading(false))
            ])
        case .googleLogin:
            return Observable.concat([
                Observable.just(Mutation.googleLoading(true)),
                Observable.create { observer in
                    print("loginWithGoogle() success.")
                    
                    // 로그인 성공 시 Mutation.login 값 방출
                    observer.onNext(.googleLogin)
                    
                    // 로그인 성공 후, 사용자 정보 가져오기
                    self.startGoogleLogin()
                    
                    // 이벤트 방출 후 Observable 작업 완료. 더 이상 값 방출 X
                    observer.onCompleted()
                    
                    return Disposables.create()
                },
                Observable.just(Mutation.googleLoading(false))
            ])
        }
    }
    
    // MARK: - 변이를 기반으로 상태를 업데이트하는 로직을 구현합니다.
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .kakaoLogin:
            newState.isKakaoLoggedIn = true
        case .googleLogin:
            newState.isGoogleLoggedIn = true
        case .kakaoLoading(let shouldShow):
            newState.isKakaoLoading = shouldShow
            if shouldShow == false { newState.isKakaoLoggedIn = false }
        case .googleLoading(let shouldShow):
            newState.isGoogleLoading = shouldShow
            if shouldShow == false { newState.isGoogleLoggedIn = false }
        }
        return newState
    }
    
    // MARK: - 사용자 정보 가져오기
    func getUserInfo() {
        UserApi.shared.rx.me()
            .subscribe (onSuccess:{ user in
                print("🔎 ##### 카카오 사용자 정보 조회 성공 #####")
                print("userNickname :", user.properties?["nickname"] ?? "unknown_token")
                print("userEmail :", user.kakaoAccount?.email ?? "unknown_email")
                print("userID :", user.id ?? "unknown_ID")
                self.checkToken() // 토큰 조회
                //do something
                _ = user
            }, onFailure: {error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 토큰 정보 보기
    func checkToken() { // 사용자 액세스 토큰 정보 조회
        UserApi.shared.rx.accessTokenInfo()
            .subscribe(onSuccess:{ (accessTokenInfo) in
                print("accessToken: \(accessTokenInfo.self)")
                
                //do something
                _ = accessTokenInfo
                
            }, onFailure: {error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - 구글 로그인
    private func startGoogleLogin() {
        guard let viewController = UIApplication.getMostTopViewController() else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { userInfo, error in
            print("🔎 ##### 구글 사용자 정보 조회 성공 #####")
            print("userInfo: ", userInfo ?? "unknown")
            print("accessToken: ", userInfo?.user.accessToken ?? "unknown_accessToken")
            print("idToken: ", userInfo?.user.idToken ?? "unknown_idToken")
            print("userID: ", userInfo?.user.userID ?? "unknown_userID")
            print("userName: ", userInfo?.user.profile?.email ?? "unknown_profile")
        }
    }
}
