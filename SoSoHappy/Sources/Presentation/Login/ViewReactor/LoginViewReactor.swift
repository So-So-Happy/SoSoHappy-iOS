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

// Kakao SDK 로그인
// Userdefaults, fetchToken
//

class LoginViewReactor: Reactor {
    
    // MARK: - Class member property
    let disposeBag = DisposeBag()
    
    let initialState: State
    private let repository: UserRepository
    private let userDefaults: LocalStorageService
    private let kakaoManager: SigninManagerProtocol
    private let appleManager: SigninManagerProtocol
    
    // MARK: - Init
    init(
        repository: UserRepository,
        userDefaults: LocalStorageService,
        kakaoManager: SigninManagerProtocol,
        appleManager: SigninManagerProtocol,
        state: State = State()
    ) {
        self.repository = repository
        self.userDefaults = userDefaults
        self.kakaoManager = kakaoManager
        self.appleManager = appleManager
        self.initialState = state
    }
    
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
        case showErrorAlert(Error)
    }
    
    // MARK: - 뷰의 상태를 정의합니다. (현재 상태 기록)
    struct State {
        var isKakaoLoggedIn = false
        var isKakaoLoading = false
        var isGoogleLoggedIn = false
        var isGoogleLoading = false
        var showErrorAlert: Error?

    }
    
    // MARK: - 액션에서 변이로의 로직을 구현합니다. (Action이 들어온 경우, 어떤 처리를 할건지 분기)
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoLogin:
            // 여기에서 비동기 작업을 수행하고 해당하는 변이를 방출합니다.
            // 예: 실제 로그인 요청 및 결과에 따른 변이 방출
            return Observable.concat([
                Observable.just(Mutation.kakaoLoading(true)),
                self.signinWithKakao()
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
//
//        case .fetchToken:
//            return repository.kakaoLogin()
//                .map { Mutation.fetchToken($0) }
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
        case .showErrorAlert(let error):
            newState.showErrorAlert = error
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
                self.userDefaults.write(key: .userAccount, value: user.kakaoAccount?.email ?? "")
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
                self.userDefaults.write(key: .token, value: accessTokenInfo.self)
                //do something
                _ = accessTokenInfo
                // keychain (key)
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
            
            // keychain에 저장
        }
    }
    
    private func signinWithKakao() -> Observable<Mutation> {
        self.kakaoManager.signin()
            .flatMap { [weak self] signinRequest -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                self.getUserInfo() // userdefault email 저장
//                token 저장할 수 있음.
                return self.signin(request: signinRequest)
            }
            .catch { error in
                if case .custom(let message) = error as? BaseError,
                   message == "cancel" {
                    return .just(.kakaoLoading(false))
                } else {
                    return .just(.showErrorAlert(error))
                }
            }
    }
    
//      private func signinWithApple() -> Observable<Mutation> {
//          return self.appleManager.signin()
//              .flatMap { [weak self] signinRequest -> Observable<Mutation> in
//                  guard let self = self else { return .error(BaseError.unknown) }
//
//                  return self.signin(request: signinRequest)
//              }
//              .catch { error in
//                  if case .custom(let message) = error as? BaseError,
//                     message == "cancel" {
//                      return .just(.showLoading(isShow: false))
//                  } else {
//                      return .just(.showErrorAlert(error))
//                  }
//              }
//      }
    
    private func signin(request: SigninRequest) -> Observable<Mutation> {
        return repository.kakaoLogin()
            .asObservable()
            .do(onNext: { signinResponse in
                print("access: \(signinResponse.Authorization)")
                print("refresh: \(signinResponse.AuthorizationRefresh)")
                KeychainService.saveData(serviceIdentifier: "", forKey: "accessToken", data: signinResponse.Authorization)
                KeychainService.saveData(serviceIdentifier: "", forKey: "refreshToken", data: signinResponse.AuthorizationRefresh)
            })
            .flatMap { _ in
                return Observable.just(Mutation.kakaoLoading(false))
            }
            .catch { error in
                return .just(Mutation.showErrorAlert(HTTPError.unauthorized))
            }
    }

}
