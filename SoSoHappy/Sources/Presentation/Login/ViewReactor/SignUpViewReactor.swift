//
//  SignUpViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/30.
//

import ReactorKit
import RxCocoa
import RxSwift

class SignUpViewReactor: Reactor {
    
    // MARK: - Class member property
    private let userRepository = UserRepository()
    
    // MARK: - Action
    enum Action {
        case selectImage(UIImage?)
        case nickNameTextChanged(String)
        case selfIntroTextChanged(String)
        case checkDuplicate
        case signUp
    }
    
    // MARK: - Mutation
    enum Mutation {
        case setImage(UIImage?)
        case setNickNameText(String)
        case setSelfIntroText(String)
        case isDuplicate(Bool)
        case signUpSuccessed(Bool)
    }
    
    // MARK: - State
    struct State {
        var profileImage: UIImage
        var nickNameText: String
        var selfIntroText: String
        var isDuplicate: Bool?
        var signUpSuccessed: Bool?
    }
    
    // MARK: - Init
    
    let initialState: State
    
    init() {
        initialState = State(profileImage: UIImage(named: "profile")!, nickNameText: "", selfIntroText: "")
    }
    
    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .selectImage(image):
            return Observable.just(Mutation.setImage(image))
            
        case let .nickNameTextChanged(text):
            return Observable.just(Mutation.setNickNameText(text))
            
        case let .selfIntroTextChanged(text):
            return Observable.just(Mutation.setSelfIntroText(text))
            
        case .checkDuplicate:
            // 중복 검사 API -> 결과 (중복 - true, 중복 x - false)
            return userRepository.checkDuplicateNickname(request: CheckNickNameRequest(nickName: currentState.nickNameText))
                .map { Mutation.isDuplicate(Bool($0.isPresent)) }
            
        case .signUp:
            let trimmedSelfIntroText = currentState.selfIntroText.trimTrailingWhitespaces() // 뒤에 위치한 공백 제거 selfIntroText 넘겨줄 것
            let email = KeychainService.loadData(serviceIdentifier: "sosohappy.tokens", forKey: "userEmail") ?? ""
            let nickName = currentState.nickNameText
            let profileImage = currentState.profileImage
            let intro = trimmedSelfIntroText
            
            return userRepository.setProfile(profile: Profile(email: email, nickName: nickName, profileImg: profileImage, introduction: intro))
                .map { Mutation.signUpSuccessed($0.success) }
        }
    }
    
    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setImage(image):
            if let image = image {
                newState.profileImage = image
            }

        case let .setNickNameText(text):
            let textWithoutSpace = text.replacingOccurrences(of: " ", with: "") // 아예 스페이스가 안되도록 해줘야 함!
            let newText = String(textWithoutSpace.prefix(10)) // 10글자 제한
            newState.nickNameText = newText
            
            // 그냥 text의 값이 이전과 변했으면 중복검사를 nil로 설정해줌
            if currentState.nickNameText != newText {
                newState.isDuplicate = nil
            }
            
        case let .setSelfIntroText(text):
            newState.selfIntroText = String(text.prefix(60))    // 60자 제한
            
        case let .isDuplicate(bool):
            if !bool {
                KeychainService.saveData(serviceIdentifier: "sosohappy.userInfo", forKey: "userNickname", data: currentState.nickNameText)
            }
            newState.isDuplicate = bool
            
        case let .signUpSuccessed(bool) :
            print("💖 회원가입 \(bool ? "성공" : "실패") (in reduce() - .signUpSuccessed)")
            newState.signUpSuccessed = bool
            // fail 실패했을 때 사용자한테 alert? 이런거 띄워야 할 듯?
            // success했을 때도 사용자한테 알려주고
        }
        
        return newState
    }
}


