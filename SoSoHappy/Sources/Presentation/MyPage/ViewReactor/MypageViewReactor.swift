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
    var nickName: String
    let email: String
    
    // MARK: - Init
    init(state: State = State(profile: UIImage(), nickName: " ", email: " ", intro: " ")) {
        self.initialState = state
        self.nickName = KeychainService.getNickName()
        self.email = KeychainService.getUserEmail()
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
        
        case setProfile
        case loadingProfile(Bool)
    }
    
    // MARK: - State (뷰의 상태)
    struct State {
        var profile: UIImage
        var nickName: String
        var email: String
        var intro: String
        
        var showProfile = true
        var isProfileLoading = false
    }
    
    // MARK: - Mutate action
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            self.nickName = KeychainService.getNickName()
            let intro = KeychainService.getUserIntro()
            
            return .concat([
                .just(.loadingProfile(currentState.intro != intro || currentState.nickName != self.nickName)),
                getProfileImg(),
                getIntroduction(),
                .just(.setNickName(self.nickName)),
                .just(.setEmail(String(self.email.split(separator: "+")[0]))),
                .just(.loadingProfile(false))
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
        case .setProfile:
            newState.showProfile = true
        case .loadingProfile(let shouldShow):
            newState.isProfileLoading = shouldShow
            if !shouldShow { newState.showProfile = false }
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
