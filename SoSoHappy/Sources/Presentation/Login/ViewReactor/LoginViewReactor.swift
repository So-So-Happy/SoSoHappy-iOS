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
        case kakaoLogin
        case googleLogin
        case appleLogin
        
        case kakaoLoading(Bool)
        case googleLoading(Bool)
        case appleLoading(Bool)

        case showErrorAlert(Error)
        case clearErrorAlert
        
        case goToSignUp(Bool)
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
        
        var goToSignUp: Bool?
    }
    
    // MARK: - mutate action
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoLogin:
            return .concat([
                Observable.just(Mutation.kakaoLoading(true)),
                self.signinWithKakao(),
                Observable.just(Mutation.kakaoLoading(false)),
                Observable.just(Mutation.clearErrorAlert)
            ])
            
        case .tapGoogleLogin:
            return .concat([
                Observable.just(Mutation.googleLoading(true)),
                self.signinWithGoogle(),
                Observable.just(Mutation.googleLoading(false)),
                Observable.just(Mutation.clearErrorAlert)
            ])
            
        case .tapAppleLogin:
            return .concat([
                Observable.just(Mutation.appleLoading(true)),
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
            
        case .goToSignUp(let value):
            newState.goToSignUp = value
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
    
    // MARK: - 로그인 요청 후 토큰과 사용자 정보 가져오기 & 키체인에 토큰 저장
    private func requestSignIn(request: SigninRequest) -> Observable<Mutation> {
        return self.userRepository.signIn(request: request)
            .do(onNext: { signinResponse in
                KeychainService.saveData(serviceIdentifier: "sosohappy.tokens", forKey: "accessToken", data: signinResponse.authorization)
                KeychainService.saveData(serviceIdentifier: "sosohappy.tokens", forKey: "refreshToken", data: signinResponse.authorizationRefresh)
                KeychainService.saveData(serviceIdentifier: "sosohappy.tokens", forKey: "userEmail", data: signinResponse.email)
                KeychainService.saveData(serviceIdentifier: "sosohappy.tokens", forKey: "userNickName", data: signinResponse.nickName)
            })
            .flatMap { signinResponse -> Observable<Mutation> in
                print("✅ LoginViewReactor signIn() signinResponse : \(signinResponse)")
                return .just(.goToSignUp(true))
            }
    }
    
    // MARK: - 인증 코드 받고 로그인
    private func signIn(request: SigninRequest) -> Observable<Mutation> {
        return userRepository.getAuthorizeCode()
            .flatMap { [weak self] response -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                print("✅ LoginViewReactor signIn() .getAuthorizeCode : \(response.authorizeCode)")
                return requestSignIn(request: request)
            }
            .catch { return .just(.showErrorAlert($0)) }
    }
}
