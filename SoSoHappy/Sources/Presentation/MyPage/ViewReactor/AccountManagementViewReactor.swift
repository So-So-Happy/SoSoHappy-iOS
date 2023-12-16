//
//  AccountManagementViewReactor.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/31/23.
//

import RxSwift
import RxCocoa
import ReactorKit

class AccountManagementViewReactor: Reactor {
    
    // MARK: - Class member property
    let initialState: State
    private let kakaoManager = KakaoSigninManager()
    private let appleManager = AppleSigninManager()
    private let googleManager = GoogleSigninManager()
    private let userRepository = UserRepository()
    let email: String
    let provider: String
    
    // MARK: - Init
    init(state: State = State()) {
        self.initialState = state
        self.provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
        self.email = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(self.provider)", forKey: "userEmail") ?? ""
    }
    
    // MARK: - Action
    enum Action {
        case tapLogoutButton
        case tapResignButton
        case logout
        case resign
    }
    
    // MARK: - Mutation (처리 단위)
    enum Mutation {
        case showLogoutCheckAlert(Bool)
        case showResignCheckAlert(Bool)
        case showErrorAlert(Error)
        case clearErrorAlert
        case goToLoginView(Bool)
    }
    
    // MARK: - State (뷰의 상태)
    struct State {
        var showLogoutCheckAlert: Bool?
        var showResignCheckAlert: Bool?
        var showErrorAlert: Error?
        var goToLoginView: Bool?
    }
    
    // MARK: - Mutate action
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapLogoutButton:
            return Observable.just(Mutation.showLogoutCheckAlert(true))
            
        case .tapResignButton:
            return Observable.just(Mutation.showResignCheckAlert(true))
            
        case .logout:
            // MARK: -  로그아웃할 때 removeObserver 해줘야 해서 여기에서 post
            NotificationCenter.default.post(name: NSNotification.Name.logoutNotification, object: nil)
            return .concat([logout(), .just(Mutation.clearErrorAlert)])
            
        case .resign:
            return .concat([resign(), .just(Mutation.clearErrorAlert)])
        }
    }
    
    // MARK: - Reduce state, mutation
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .showLogoutCheckAlert(bool):
            newState.showResignCheckAlert = false
            newState.showLogoutCheckAlert = bool
            
        case let .showResignCheckAlert(bool):
            newState.showLogoutCheckAlert = false
            newState.showResignCheckAlert = bool
            
        case let .showErrorAlert(error):
            newState.showLogoutCheckAlert = false
            newState.showResignCheckAlert = false
            newState.showErrorAlert = error
            
        case .clearErrorAlert:
            newState.showErrorAlert = nil
            
        case let .goToLoginView(bool):
            newState.showLogoutCheckAlert = false
            newState.showResignCheckAlert = false
            newState.goToLoginView = bool
        }
        
        return newState
    }
    
    // MARK: - 로그아웃
    private func logout() -> Observable<Mutation> {
        switch provider {
        case "kakao":
            return kakaoManager.logout()
                .do(onNext: { _ in
                    KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "accessToken")
                    KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "refreshToken")
                })
                .flatMap { logoutResponse -> Observable<Mutation> in
                    return .just(.goToLoginView(true))
                }
                .catch { return .just(.showErrorAlert($0)) }
            
        case "google":
            return googleManager.logout()
                .do(onNext: { _ in
                    KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "accessToken")
                    KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "refreshToken")
                })
                .flatMap { logoutResponse -> Observable<Mutation> in
                    return .just(.goToLoginView(true))
                }
                .catch { return .just(.showErrorAlert($0)) }
            
        case "apple":
            return appleManager.logout()
                .do(onNext: { _ in
                    KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "accessToken")
                    KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "refreshToken")
                })
                .flatMap { logoutResponse -> Observable<Mutation> in
                    return .just(.goToLoginView(true))
                }
                .catch { return .just(.showErrorAlert($0)) }
           
        default:
            return .just(.showErrorAlert("Something's wrong." as! Error))
        }
    }
    
    // MARK: - 회원탈퇴
    private func resignWithSocialAccount() -> Observable<Mutation> {
        switch provider {
        case "kakao":
            return kakaoManager.resign()
                .flatMap { return self.resign() }
        case "google":
            return resign()
            
        case "apple":
            return resign()
        default:
            return .just(.showErrorAlert("Something's wrong." as! Error))
            
        }
    }
    
    func resign() -> Observable<Mutation> {
        return userRepository.resign(email: ResignRequest(email: self.email))
            .do(onNext: { _ in
                let provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
                KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "accessToken")
                KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "refreshToken")
                KeychainService.deleteTokenData(identifier: "sosohappy.userInfo\(provider)", account: "userEmail")
                KeychainService.deleteTokenData(identifier: "sosohappy.userInfo\(provider)", account: "userNickName")
            })
            .flatMap { resignResponse -> Observable<Mutation> in
                guard resignResponse.success else { return .just(.showErrorAlert("이메일 오류로 인해 회원탈퇴가 정상적으로 완료되지 않았습니다." as! Error)) }
                return .just(.goToLoginView(resignResponse.success))
            }
            .catch { return .just(.showErrorAlert($0)) }
    }
}
