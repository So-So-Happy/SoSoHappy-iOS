//
//  NotificationSettingViewReactor.swift
//  SoSoHappy
//
//  Created by 박민주 on 11/8/23.
//

import RxSwift
import RxCocoa
import ReactorKit

class NotificationSettingViewReactor: Reactor {
    
    // MARK: - Class member property
    let initialState: State
    private let userRepository = UserRepository()
    
    // MARK: - Init
    init(state: State = State()) {
        self.initialState = state
    }
    
    // MARK: - Action
    enum Action {
        case viewWillAppear
        case tapSwitch(Bool)
    }
    
    // MARK: - Mutation (처리 단위)
    enum Mutation {
        case setFirstNotiSetting(Bool)
        case setNotiSetting(Bool)
    }
    
    // MARK: - State (뷰의 상태)
    struct State {
        var firstSwitch: Bool?
        var onSwitch: Bool?
    }
    
    // MARK: - Mutate action
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            let setting = UserDefaults.standard.bool(forKey: "notificationSetting")
            return .just(.setFirstNotiSetting(setting))
            
        case .tapSwitch(let isOn):
            return .just(.setNotiSetting(isOn))
        }
    }
    
    // MARK: - Reduce state, mutation
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setNotiSetting(let bool):
            UserDefaults.standard.setValue(bool, forKey: "notificationSetting")
            newState.onSwitch = bool
            
        case .setFirstNotiSetting(let bool):
            newState.firstSwitch = bool
        }
        
        return newState
    }
}
