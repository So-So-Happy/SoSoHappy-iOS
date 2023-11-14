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
    let provider: String
    var nickName: String
    let email: String
    
    // MARK: - Init
    init(state: State = State(profile: UIImage(), nickName: " ", email: " ", intro: " ")) {
        self.initialState = state
        self.provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
        self.nickName = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userNickName") ?? ""
        self.email = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userEmail") ?? ""
    }
    
    // MARK: - Action
    enum Action {
        case viewWillAppear
    }
    
    // MARK: - Mutation (처리 단위)
    enum Mutation {
        case setProfileImage(UIImage)
        case setNickName(String)
        case setEmail(String)
        case setIntro(String)
    }
    
    // MARK: - State (뷰의 상태)
    struct State {
        var profile: UIImage
        var nickName: String
        var email: String
        var intro: String
    }
    
    // MARK: - Mutate action
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            self.nickName = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userNickName") ?? ""
            return .concat([
                getProfileImg(),
                getIntroduction(),
                .just(.setNickName(self.nickName)),
                .just(.setEmail(String(self.email.split(separator: "+")[0])))
            ])
        }
    }
    
    // MARK: - Reduce state, mutation
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setProfileImage(let image):
            newState.profile = image
        case .setNickName(let nickname):
            newState.nickName = nickname
        case .setEmail(let email):
            newState.email = email
        case .setIntro(let intro):
            newState.intro = intro
        }
        
        return newState
    }
}

// MARK: - Custom functions
extension NotificationSettingViewReactor {
    func getProfileImg() -> Observable<Mutation> {
        return userRepository.findProfileImg(request: FindProfileImgRequest(nickname: self.nickName))
            .flatMap { [weak self] image -> Observable<Mutation> in
                guard self != nil else { return .error(BaseError.unknown) }
                KeychainService.saveData(serviceIdentifier: "sosohappy.userInfo", forKey: "userProfile", data: (image.pngData()?.base64EncodedString(options: .lineLength64Characters))!)
                return .just(.setProfileImage(image))
            }
    }
    
    func getIntroduction() -> Observable<Mutation> {
        return userRepository.findIntroduction(request: FindIntroductionRequest(nickname: self.nickName))
            .flatMap { [weak self] intro -> Observable<Mutation> in
                guard self != nil else { return .error(BaseError.unknown) }
                KeychainService.saveData(serviceIdentifier: "sosohappy.userInfo", forKey: "userIntro", data: intro)
                return .just(.setIntro(intro))
            }
    }
}

