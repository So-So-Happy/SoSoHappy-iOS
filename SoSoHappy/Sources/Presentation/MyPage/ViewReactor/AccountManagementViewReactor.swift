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
    
    // MARK: - Init
    init(state: State = State()) {
        self.initialState = state
        self.email = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "userEmail") ?? ""
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
        return googleManager.logout()
            .do(onNext: { _ in
                KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "accessToken")
                KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "refreshToken")
            })
            .flatMap { logoutResponse -> Observable<Mutation> in
                return .just(.goToLoginView(true))
            }
            .catch { return .just(.showErrorAlert($0)) }
    }
    
    // MARK: - 회원탈퇴
    private func resign() -> Observable<Mutation> {
        return userRepository.resign(email: ResignRequest(email: self.email))
            .do(onNext: { _ in
                let provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
                KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "accessToken")
                KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "refreshToken")
                KeychainService.deleteTokenData(identifier: "sosohappy.userInfo", account: "userEmail")
                KeychainService.deleteTokenData(identifier: "sosohappy.userInfo\(provider)", account: "userNickName")
            })
            .flatMap { resignResponse -> Observable<Mutation> in
                if resignResponse.success {
                    print("✅ 회원탈퇴가 성공적으로 완료되었습니다.")
                } else { print("✅ 회원탈퇴에 실패하였습니다.") }
                return .just(.goToLoginView(resignResponse.success))
            }
            .catch { return .just(.showErrorAlert($0)) }
    }
}
