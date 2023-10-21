//
//  LoginViewReactor.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/09/01.
//

import RxSwift
import RxCocoa
import ReactorKit

class LoginViewReactor: Reactor {
    
    // MARK: - Class member property
    let disposeBag = DisposeBag()
    
    let initialState: State
    private let userRepository: UserRepository
    private let kakaoManager: SigninManagerProtocol
    private let appleManager: SigninManagerProtocol
    private let googleManager: SigninManagerProtocol
    
    // MARK: - Init
    init(
        userRepository: UserRepository,
        kakaoManager: SigninManagerProtocol,
        appleManager: SigninManagerProtocol,
        googleMagager: SigninManagerProtocol,
        state: State = State()
    ) {
        self.userRepository = userRepository
        self.kakaoManager = kakaoManager
        self.appleManager = appleManager
        self.googleManager = googleMagager
        self.initialState = state
    }
    
    // MARK: - 가능한 액션을 정의
    enum Action {
        case tapKakaoLogin
        case tapGoogleLogin
        case tapAppleLogin
    }
    
    // MARK: - 액션에 대응하는 변이를 정의 (처리 단위)
    enum Mutation {
        case getAuthorizeCode(AuthCodeResponse)
        case signIn(AuthResponse)
        
        case kakaoLogin
        case googleLogin
        case appleLogin
        
        case kakaoLoading(Bool)
        case googleLoading(Bool)
        case appleLoading(Bool)

        case showErrorAlert(Error)
        case clearErrorAlert
        
        case goToMain(Bool)
    }
    
    // MARK: - 뷰의 상태를 정의 (현재 상태 기록)
    struct State {
        var isKakaoLoggedIn = false
        var isKakaoLoading = false
        
        var isGoogleLoggedIn = false
        var isGoogleLoading = false
        
        var isAppleLoggedIn = false
        var isAppleLoading = false
        
        var showErrorAlert: Error?
        
        var goToMain: Bool = false
    }
    
    // MARK: - mutate action
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoLogin:
            // TODO: 서버 오류로 인한 테스트 코드
            return Observable.just(Mutation.goToMain(true))
//            return .concat([
//                Observable.just(Mutation.kakaoLoading(true)),
//                userRepository.getAuthorizeCode()
//                    .map { Mutation.getAuthorizeCode($0) },
//                self.signinWithKakao(),
//                Observable.just(Mutation.kakaoLoading(false)),
//                Observable.just(Mutation.clearErrorAlert)
//            ])
            
        case .tapGoogleLogin:
            return .concat([
                Observable.just(Mutation.googleLoading(true)),
                userRepository.getAuthorizeCode()
                    .map { Mutation.getAuthorizeCode($0) },
                self.signinWithGoogle(),
                Observable.just(Mutation.googleLoading(false)),
                Observable.just(Mutation.clearErrorAlert)
            ])
            
        case .tapAppleLogin:
            return .concat([
                Observable.just(Mutation.appleLoading(true)),
                userRepository.getAuthorizeCode()
                    .map { Mutation.getAuthorizeCode($0) },
                self.signinWithApple(),
                Observable.just(Mutation.appleLoading(false)),
                Observable.just(Mutation.clearErrorAlert)
            ])
        }
    }
    
    // MARK: - reduce state, mutation
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .getAuthorizeCode(let authCode):
            print("✅ LoginViewReactor reduce() .getAuthorizeCode : \(authCode)")
           
        case .signIn(let auth):
            print("✅ LoginViewReactor reduce() .signIn : \(auth)")
            
        case .kakaoLogin:
            newState.isKakaoLoggedIn = true
            
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

        case .clearErrorAlert:
            newState.showErrorAlert = nil
            
        case .goToMain(let value):
            newState.goToMain = value
        }
        
        return newState
    }
    
    // MARK: - 카카오 로그인
    private func signinWithKakao() -> Observable<Mutation> {
        self.kakaoManager.signin()
            .flatMap { [weak self] signinRequest -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                return self.signIn(request: signinRequest)
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
    private func signinWithGoogle() -> Observable<Mutation> {
        self.googleManager.signin()
            .flatMap { [weak self] signinRequest -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                return self.signIn(request: signinRequest)
            }
            .catch { error in
                print("⚠️ google login error:", error)
                return .just(.googleLoading(false))
            }
    }
    
    // MARK: - 애플 로그인
    private func signinWithApple() -> Observable<Mutation> {
        return self.appleManager.signin()
            .flatMap { [weak self] signinRequest -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                return self.signIn(request: signinRequest)
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
    
    // MARK: - 로그인 성공 후 토큰과 사용자 정보 가져오기 & 키체인에 토큰 저장
    private func signIn(request: SigninRequest) -> Observable<Mutation> {
        return userRepository.signIn(request: request)
            .do(onNext: { signinResponse in
                KeychainService.saveData(serviceIdentifier: "sosohappy.tokens", forKey: "accessToken", data: signinResponse.authorization)
                KeychainService.saveData(serviceIdentifier: "sosohappy.tokens", forKey: "refreshToken", data: signinResponse.authorizationRefresh)
            })
            .flatMap { [weak self] signinResponse -> Observable<Mutation> in
                guard self != nil else { return .error(BaseError.unknown) }
                return .just(.signIn(signinResponse))
                    .map { _ in .goToMain(true) }
            }
            .catch { return .just(.showErrorAlert($0)) }
    }
}
