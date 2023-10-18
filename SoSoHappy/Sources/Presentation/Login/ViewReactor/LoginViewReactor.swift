//
//  LoginViewReactor.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/09/01.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxKakaoSDKAuth
import RxKakaoSDKUser
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn
import AuthenticationServices

class LoginViewReactor: Reactor {
    
    // MARK: - Class member property
    let disposeBag = DisposeBag()
    
    let initialState: State
    private let userRepository: UserRepository
    private let userDefaults: LocalStorageService
    private let kakaoManager: SigninManagerProtocol
    private let appleManager: SigninManagerProtocol
    
    // MARK: - Init
    init(
        userRepository: UserRepository,
        userDefaults: LocalStorageService,
        kakaoManager: SigninManagerProtocol,
        appleManager: SigninManagerProtocol,
        state: State = State()
    ) {
        self.userRepository = userRepository
        self.userDefaults = userDefaults
        self.kakaoManager = kakaoManager
        self.appleManager = appleManager
        self.initialState = state
    }
    
    // MARK: - 가능한 액션을 정의합니다.
    enum Action {
        case tapKakaoLogin
        case tapGoogleLogin
        case tapAppleLogin
    }
    
    // MARK: - 액션에 대응하는 변이를 정의합니다. (처리 단위)
    enum Mutation {
        case getAuthorizeCode(AuthCodeResponse)
        case kakaoLogin
        case googleLogin
        case appleLogin
        
        case kakaoLoading(Bool)
        case googleLoading(Bool)
        case appleLoading(Bool)
        
        case goToMain
        
        case showErrorAlert(Error)
    }
    
    // MARK: - 뷰의 상태를 정의합니다. (현재 상태 기록)
    struct State {
        var isKakaoLoggedIn = false
        var isKakaoLoading = false
        
        var isGoogleLoggedIn = false
        var isGoogleLoading = false
        
        var isAppleLoggedIn = false
        var isAppleLoading = false
        
        var goToMain: Void?
        
        var showErrorAlert: Error?
    }
    
    // MARK: - 액션에서 변이로의 로직을 구현합니다. (Action이 들어온 경우, 어떤 처리를 할건지 분기)
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoLogin:
            return Observable.concat([
                Observable.just(Mutation.kakaoLoading(true)),
                userRepository.getAuthorizeCode()
                    .map { Mutation.getAuthorizeCode($0) },
                self.signinWithKakao(),
                Observable.just(Mutation.kakaoLoading(false))
            ])
        case .tapGoogleLogin:
            return Observable.concat([
                Observable.just(Mutation.googleLoading(true)),
                self.startGoogleLogin(),
                Observable.just(Mutation.googleLoading(false))
            ])
        case .tapAppleLogin:
            return Observable.concat([
                Observable.just(Mutation.appleLoading(true)),
                self.signinWithApple(),
                Observable.just(Mutation.appleLoading(false))
            ])
        }
    }
    
    // MARK: - 변이를 기반으로 상태를 업데이트하는 로직을 구현합니다.
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .getAuthorizeCode(let authCode):
            print("LoginViewReactor reduce() .getAuthorizeCode : \(authCode)")
            
        case .kakaoLogin:
            newState.isKakaoLoggedIn = true
            // Key Chain에 토큰들 저장하기
            
        case .googleLogin:
            newState.isGoogleLoggedIn = true
            
        case .appleLogin:
            newState.isAppleLoggedIn = true
            
        case .kakaoLoading(let shouldShow):
            newState.isKakaoLoading = shouldShow
            if shouldShow == false { newState.isKakaoLoggedIn = false }
            
        case .googleLoading(let shouldShow):
            newState.isGoogleLoading = shouldShow
            if shouldShow == false { newState.isGoogleLoggedIn = false }
            
        case .appleLoading(let shouldShow):
            newState.isAppleLoading = shouldShow
            if shouldShow == false { newState.isAppleLoggedIn = false }
            
        case .showErrorAlert(let error):
            newState.showErrorAlert = error
        
        case .goToMain:
            newState.goToMain = ()
        }
        
        return newState
    }
    
    // MARK: - 카카오 로그인
    private func signinWithKakao() -> Observable<Mutation> {
        self.kakaoManager.signin()
            .flatMap { [weak self] signinRequest -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                return Observable.empty() // self.signin(request: signinRequest)
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
    
    //MARK: - 구글 로그인
    private func startGoogleLogin() -> Observable<Mutation> {
        return Observable.create { observer in
            guard let viewController = UIApplication.getMostTopViewController() else {
                observer.onError(BaseError.unknown)
                return Disposables.create()
            }
            GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { userInfo, error in
                if error != nil {
                    observer.onNext(.googleLoading(false))
                    observer.onCompleted()
                } else if let userInfo = userInfo {
                    print("🔎 ##### 구글 사용자 정보 조회 성공 #####")
                    print("userInfo: ", userInfo)
                    print("accessToken: ", userInfo.user.accessToken)
                    print("idToken: ", userInfo.user.idToken ?? "unknown_idToken")
                    print("userID: ", userInfo.user.userID ?? "unknown_userID")
                    print("userName: ", userInfo.user.profile?.email ?? "unknown_profile")
                    observer.onCompleted() // 성공적으로 처리되었으므로 Completed 이벤트 전달
                } else {
                    observer.onError(BaseError.unknown)
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK: - 애플 로그인
    private func signinWithApple() -> Observable<Mutation> {
        return self.appleManager.signin()
            .flatMap { [weak self] signinRequest -> Observable<Mutation> in
                guard self != nil else { return .error(BaseError.unknown) }
                return Observable.empty() // TODO: 임시
            }
            .catch { error in
                if case .custom(let message) = error as? BaseError,
                   message == "cancel" {
                    return .just(.appleLoading(false))
                } else {
                    return .just(.showErrorAlert(error))
                }
            }
    }
    
//    private func signin(request: SigninRequest) -> Observable<Mutation> {
//        return userRepository.kakaoLogin(request: request)
//            .asObservable()
//            .do(onNext: { [weak self] signinResponse in
//                print(signinResponse.Authorization)
//                print(signinResponse.AuthorizationRefresh)
//            })
//            .flatMap { [weak self] _ -> Observable<Mutation> in
//                guard let self = self else { return .error(BaseError.unknown) }
//                return Observable.empty() // TODO: 임시
//            }
//            .catch { error in
//                return .just(Mutation.showErrorAlert(HTTPError.unauthorized))
//            }
//    }
}
