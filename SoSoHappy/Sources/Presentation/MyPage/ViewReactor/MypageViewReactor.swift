//
//  MypageViewReactor.swift
//  SoSoHappy
//
//  Created by 박민주 on 11/1/23.
//

import RxSwift
import RxCocoa
import ReactorKit

class MypageViewReactor: Reactor {
    
    // MARK: - Class member property
    let initialState: State
    private let userRepository = UserRepository()
    let provider: String
    let nickName: String
    let email: String
    
    // MARK: - Init
    init(state: State = State(profile: UIImage(), nickName: "", email: "", intro: "")) {
        self.initialState = state
        self.provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
        self.nickName = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userNickName") ?? ""
        self.email = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "userEmail") ?? ""
    }
    
    // MARK: - Action
    enum Action {
        case viewDidLoad
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
        case .viewDidLoad:
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
extension MypageViewReactor {
    func getProfileImg() -> Observable<Mutation> {
        return userRepository.findProfileImg(request: FindProfileImgRequest(nickname: self.nickName))
            .flatMap { [weak self] image -> Observable<Mutation> in
                guard self != nil else { return .error(BaseError.unknown) }
                return .just(.setProfileImage(image))
            }
    }
    
    func getIntroduction() -> Observable<Mutation> {
        return userRepository.findIntroduction(request: FindIntroductionRequest(nickname: self.nickName))
            .flatMap { [weak self] intro -> Observable<Mutation> in
                guard self != nil else { return .error(BaseError.unknown) }
                return .just(.setIntro(intro))
            }
    }
}
